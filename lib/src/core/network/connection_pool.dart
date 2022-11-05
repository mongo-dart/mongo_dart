import 'package:mongo_dart/src/core/error/connection_exception.dart';

import '../info/server_config.dart';
import 'abstract/connection_base.dart';

enum PoolState { closed, connected, unknown }

class ConnectionPool {
  ConnectionPool(this.serverConfig);

  ServerConfig serverConfig;
  int _idCounter = 0;
  PoolState state = PoolState.closed;
  final Set<ConnectionBase> _connections = <ConnectionBase>{};
  final Map<int, ConnectionBase> availableConnections = <int, ConnectionBase>{};

  bool get isConnected => state == PoolState.connected;

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
  }

  ConnectionBase addConnection() {
    var connection = ConnectionBase(++_idCounter, serverConfig);
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
}
