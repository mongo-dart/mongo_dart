import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mongo_dart/src/settings/connection_pool_settings.dart';

import '../../settings/default_settings.dart';
import '../../utils/events.dart';
import '../../utils/generic_error.dart';
import '../error/mongo_dart_error.dart';
import '../info/server_config.dart';
import 'abstract/connection_base.dart';
import 'abstract/connection_events.dart';
import 'connection_pool_events.dart';

enum PoolState { closed, connected, unknown }

class ConnectionPool with EventEmitter {
  ConnectionPool(this.serverConfig, this.poolSettings);

  final log = Logger('Connection Pool');

  final ServerConfig serverConfig;
  final ConnectionPoolSettings poolSettings;

  /// The maximum number of connections in the connection pool.
  /// The default value is 100.
  int get maxPoolSize => poolSettings.maxPoolSize;

  /// The minimum number of connections in the connection pool.
  /// They are created during the initial pool connection phase.
  /// The default value is 0.
  int get minPoolSize => poolSettings.minPoolSize;

  /// The maximum number of milliseconds that a connection can remain
  /// idle in the pool before being removed and closed.
  int get maxIdleTimeMS => poolSettings.maxIdleTimeMS;

  /// A number that the driver multiplies the maxPoolSize value to,
  ///  to provide the maximum number of threads allowed to wait for a
  /// connection to become available from the pool.
  /// For default values, see the driver documentation.
  int get waitQueueMultiple => poolSettings.waitQueueMultiple;

  /// The maximum time in milliseconds that a thread can wait
  /// for a connection to become available. For default values,
  /// see the driver documentation.
  int get waitQueueTimeoutMS => poolSettings.waitQueueTimeoutMS;

  PoolState state = PoolState.closed;
  final Set<ConnectionBase> _connections = <ConnectionBase>{};
  final Map<int, ConnectionBase> availableConnections = <int, ConnectionBase>{};
  bool doNotAcceptAnyRequest = false;
  final waitingList = <int>[];

  bool get isConnected => state == PoolState.connected;
  int get connectionsNumber => _connections.length;

  Future<void> connectPool() async {
    if (state == PoolState.connected) {
      return;
    }
    if (availableConnections.isNotEmpty) {
      state = PoolState.connected;
      return;
    }
    ConnectionBase connection;

    connection = _connections.firstWhere((element) => element.isClosed,
        orElse: addConnection);

    await connectConnection(connection);

    if (minPoolSize > 0) {
      while (minPoolSize > connectionsNumber) {
        var connection = addConnection();
        await connectConnection(connection);
      }
    }
  }

  ConnectionBase addConnection() {
    var connection = ConnectionBase(serverConfig);
    addListeners(connection);
    _connections.add(connection);
    return connection;
  }

  Future<void> connectConnection(ConnectionBase connection) async =>
      await connection.connect();

  ConnectionBase removeConnection(int id) {
    var connection = _connections.firstWhere((element) => element.id == id);
    connection.close();
    removeListeners(connection);
    _connections.remove(connection);
    return connection;
  }

  Future<ConnectionBase> getAvailableConnection() async {
    if (doNotAcceptAnyRequest) {
      var error =
          MongoDartError('Request rejected as pool closing is running ');
      log.finer('Request rejected as pool closing is running ');
      await emit(ConnectionPoolError(error));
      log.severe(error.originalErrorMessage);
      throw error;
    }
    if (availableConnections.isNotEmpty) {
      log.finer('Connection available - first '
          '${availableConnections.entries.first.key}');
      return _pickAvailableConnection();
    }
    if (maxPoolSize <= connectionsNumber) {
      return _queueForAvailableConnection();
    }
    log.finer('No connection available - adding a new one');
    var connection = addConnection();
    await connectConnection(connection);
    return connection.isAvailable
        ? connection
        : await _pickAvailableConnection();
  }

  Future<ConnectionBase> _queueForAvailableConnection() async {
    var startMS = DateTime.now().millisecondsSinceEpoch;
    waitingList.add(startMS);
    while (availableConnections.isEmpty || startMS != waitingList.first) {
      if (doNotAcceptAnyRequest) {
        break;
      }
      log.finer('Waiting in available connection queue');
      print('Waiting for available connection queue');
      await Future.delayed(Duration(milliseconds: defQueueTimeoutPollingMS));
      print(
          'Waited for available connection queue, waitQueueMS is $waitQueueTimeoutMS');
      if (waitQueueTimeoutMS > 0) {
        var checkMS = DateTime.now().millisecondsSinceEpoch;
        print('${(checkMS - startMS)} > $waitQueueTimeoutMS');
        if ((checkMS - startMS) > waitQueueTimeoutMS) {
          waitingList.remove(startMS);
          var error = MongoDartError(
              'Waiting time for available connection has been exceeded');
          log.warning(error.originalErrorMessage);
          await emit(ConnectionPoolError(error));
          throw error;
        }
      }
      print('Checking for exit from while loop on queue');
    }
    waitingList.removeAt(0);
    return _pickAvailableConnection();
  }

  Future<ConnectionBase> _pickAvailableConnection() async {
    if (availableConnections.isEmpty) {
      await _closeOnError(MongoDartError('No Available Connection'));
    }
    var entry = availableConnections.entries.first;
    availableConnections.remove(entry.key);
    log.finer('Got available connection No ${entry.value.id}');
    return entry.value;
  }

  Future<void> _closePool() async {
    if (doNotAcceptAnyRequest) {
      var error = MongoDartError('Pool closing already in progress');
      log.warning(error.originalErrorMessage);
      await emit(ConnectionPoolError(error));
      throw error;
    }
    doNotAcceptAnyRequest = true;
    for (var connection in _connections) {
      await connection.close();
    }
    while (waitingList.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: defQueueTimeoutPollingMS));
    }
    await emit(ConnectionPoolClosed());
    state = PoolState.closed;
    doNotAcceptAnyRequest = false;
  }

  Future<void> _closeOnError(GenericError error) async {
    await _closePool();
    log.severe(error.originalErrorMessage);
    await emit(ConnectionPoolError(error));
    throw error;
  }

  Future<void> closePool() => _closePool();

  // ****************  RECEIVING MESSAGES
  void addListeners(ConnectionBase connection) {
    connection.on<ConnectionError>(connectionErrorListener);
    connection.on<Connected>(connectedListener);
    connection.on<ConnectionClosed>(connectionClosedListener);
    connection.on<ConnectionActive>(connectionActive);
    connection.on<ConnectionAvailable>(connectionAvailable);
    connection.on<ConnectionMessageReceived>(connectionMessageReceived);
  }

  void removeListeners(ConnectionBase connection) {
    connection.off<ConnectionError>(connectionErrorListener);
    connection.off<Connected>(connectedListener);
    connection.off<ConnectionClosed>(connectionClosedListener);
    connection.off<ConnectionActive>(connectionActive);
    connection.off<ConnectionAvailable>(connectionAvailable);
    connection.off<ConnectionMessageReceived>(connectionMessageReceived);
  }

  // *************  Connection Listeners ************************
  FutureOr<void> connectionErrorListener(ConnectionError event) async {
    _connections.removeWhere((element) => element.id == event.id);
    if (_connections.isEmpty) {
      await _closeOnError(event.error);
    }
  }

  FutureOr<void> connectedListener(Connected event) =>
      state = PoolState.connected;

  FutureOr<void> connectionClosedListener(ConnectionClosed event) {
    availableConnections.remove(event.id);
    _connections.removeWhere((element) => element.id == event.id);
  }

  FutureOr<void> connectionActive(ConnectionActive event) {
    log.finer('Connection ${event.id} active');
    availableConnections.remove(event.id);
  }

  FutureOr<void> connectionAvailable(ConnectionAvailable event) {
    log.finer('Connection ${event.id} available');

    availableConnections[event.id] =
        _connections.firstWhere((element) => element.id == event.id);
  }

  FutureOr<void> connectionMessageReceived(ConnectionMessageReceived event) {
    log.finer('Received message on connection ${event.id}');
    availableConnections[event.id] =
        _connections.firstWhere((element) => element.id == event.id);
  }
}
