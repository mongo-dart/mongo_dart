import 'dart:async';

import 'package:mongo_dart/src/core/error/connection_exception.dart';

import '../info/server_config.dart';
import 'abstract/connection_base.dart';
import 'abstract/connection_events.dart';

enum PoolState { closed, connected, unknown }

class ConnectionPool {
  ConnectionPool(this.serverConfig);

  ServerConfig serverConfig;
  PoolState state = PoolState.closed;
  final Set<ConnectionBase> _connections = <ConnectionBase>{};
  final Map<int, ConnectionBase> availableConnections = <int, ConnectionBase>{};
  bool doNotAcceptAnyRequest = false;

  bool get isConnected => state == PoolState.connected;

  Future<void> connectPool() async {
    if (state == PoolState.connected) {
      throw ConnectionException('Pool Closing, please wait a while and retry');
    }
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
  }

  ConnectionBase addConnection() {
    var connection = ConnectionBase(serverConfig);
    addListeners(connection);
    _connections.add(connection);
    return connection;
  }

  Future<void> connectConnection(ConnectionBase connection) async {
    await connection.connect();
    if (connection.isAvailable) {
      availableConnections[connection.id] = connection;
      state = PoolState.connected;
    }
  }

  ConnectionBase removeConnection(int id) {
    var connection = _connections.firstWhere((element) => element.id == id);
    connection.close();
    removeListeners(connection);
    _connections.remove(connection);
    return connection;
  }

  Future<ConnectionBase> getAvailableConnection() async {
    if (availableConnections.isNotEmpty) {
      return pickAvailableConnection();
    }
    var connection = addConnection();
    await connectConnection(connection);
    return pickAvailableConnection();
  }

  ConnectionBase pickAvailableConnection() {
    if (availableConnections.isEmpty) {
      throw ConnectionException('No available Connection');
    }
    var entry = availableConnections.entries.first;
    availableConnections.remove(entry.key);
    return entry.value;
  }

  void addListeners(ConnectionBase connection) {
    connection.on<ConnectionError>(connectionErrorListener);
  }

  void removeListeners(ConnectionBase connection) {
    connection.off<ConnectionError>(connectionErrorListener);
  }

  Future<void> closePool() async {
    doNotAcceptAnyRequest = true;
    for (var connection in _connections) {
      await connection.close();
    }
    doNotAcceptAnyRequest = false;
  }

  // *************  Listeners ************************
  FutureOr<void> connectionErrorListener(ConnectionError event) {
    _connections.removeWhere((element) => element.id == event.id);
    if (_connections.isEmpty) {
      state = PoolState.closed;
    }
  }

  FutureOr<void> connectedListener(Connected event) {
    availableConnections[event.id] =
        _connections.firstWhere((element) => element.id == event.id);
  }

  FutureOr<void> connectionClosedListener(ConnectionClosed event) {
    _connections.removeWhere((element) => element.id == event.id);
    if (_connections.isEmpty) {
      state = PoolState.closed;
    }
  }

  FutureOr<void> connectionActive(ConnectionActive event) {
    availableConnections.remove(event.id);
  }

  FutureOr<void> connectionAvailable(ConnectionActive event) {
    availableConnections[event.id] =
        _connections.firstWhere((element) => element.id == event.id);
  }
}
