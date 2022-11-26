import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mongo_dart/src/core/error/connection_exception.dart';

import '../core/error/mongo_dart_error.dart';
import '../core/info/server_capabilities.dart';
import '../core/info/server_config.dart';
import '../core/info/server_status.dart';
import '../core/message/abstract/section.dart';
import '../core/message/mongo_modern_message.dart';
import '../core/network/connection_pool.dart';

enum ServerState { closed, connected }

class Server {
  Server(this.serverConfig) : connectionPool = ConnectionPool(serverConfig);

  final Logger log = Logger('Server');
  final ServerConfig serverConfig;
  final ConnectionPool connectionPool;
  final ServerCapabilities serverCapabilities = ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();

  ServerState state = ServerState.closed;

  bool get isAuthenticated => serverConfig.isAuthenticated;
  bool get isConnected => state == ServerState.connected;

  Future<void> connect() async {
    if (state == ServerState.connected) {
      return;
    }
    await connectionPool.connectPool();
    if (!connectionPool.isConnected) {
      throw ConnectionException('No Connection Available');
    }
    state = ServerState.connected;
  }

  Future<void> close() async {
    await connectionPool.closePool();
    return;
  }

  Future<Map<String, Object?>> executeMessage(
      MongoModernMessage message) async {
    if (state != ServerState.connected) {
      throw MongoDartError('Server is not is not connected. $state');
    }

    var connection = await connectionPool.getAvailableConnection();

    var response = await connection.execute(message);

    var section = response.sections.firstWhere((Section section) =>
        section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }
}
