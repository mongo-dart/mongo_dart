import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mongo_dart/src/core/error/connection_exception.dart';
import 'abstract/connection_base.dart';

import '../info/server_capabilities.dart';
import '../info/server_config.dart';
import '../info/server_status.dart';
import 'connection_pool.dart';

enum ServerState { closed, connected }

class Server {
  Server({ServerConfig? serverConfig})
      : serverConfig = serverConfig ?? ServerConfig() {
    connectionPool = ConnectionPool(this.serverConfig);
  }

  final Logger log = Logger('Server');
  ServerConfig serverConfig;
  late ConnectionPool connectionPool;
  ServerState status = ServerState.closed;

  final ServerCapabilities serverCapabilities = ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();

  bool get isAuthenticated => serverConfig.isAuthenticated;

  Future<void> connect() async {
    if (status == ServerState.connected) {
      return;
    }
    await connectionPool.connectPool();
    if (!connectionPool.isConnected) {
      throw ConnectionException('No Connection Available');
    }
    status = ServerState.connected;
  }

  Future<void> close() async {
    //_closed = true;
    //connected = false;
    //await socket?.close();
    return;
  }
}
