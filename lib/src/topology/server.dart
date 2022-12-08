import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/core/error/connection_exception.dart';
import 'package:mongo_dart/src/settings/connection_pool_settings.dart';

import '../core/error/mongo_dart_error.dart';
import '../core/info/server_capabilities.dart';
import '../core/info/server_config.dart';
import '../core/info/server_status.dart';
import '../core/message/abstract/section.dart';
import '../core/message/mongo_modern_message.dart';
import '../core/network/connection_pool.dart';

enum ServerState { closed, connected }

class Server {
  Server(this.serverConfig, ConnectionPoolSettings poolSettings)
      : connectionPool = ConnectionPool(serverConfig, poolSettings);

  final Logger log = Logger('Server');
  final ServerConfig serverConfig;
  final ServerCapabilities serverCapabilities = ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();
  final ConnectionPool connectionPool;

  ServerState state = ServerState.closed;
  HelloResult? hello;

  bool get isAuthenticated => serverConfig.isAuthenticated;
  bool get isConnected => state == ServerState.connected;

  bool get isStandalone => serverCapabilities.isStandalone;
  bool get isReplicaSet => serverCapabilities.isReplicaSet;
  bool get isShardedCluster => serverCapabilities.isShardedCluster;

  Future<void> connect() async {
    if (state == ServerState.connected) {
      return;
    }
    await connectionPool.connectPool();
    if (!connectionPool.isConnected) {
      throw ConnectionException('No Connection Available');
    }
    state = ServerState.connected;
    await _runHello();
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

  Future<void> refreshStatus() => _runHello();

  Future<void> _runHello() async {
    Map<String, Object?> result = {keyOk: 0.0};
    try {
      var helloCommand = HelloCommand(this, username: serverConfig.userName);
      result = await helloCommand.execute();
    } catch (e) {
      //Do nothing
    }
    if (result[keyOk] == 1.0) {
      hello = HelloResult(result);
      var master = hello!.isWritablePrimary;
      /* connection.isMaster = master;
      if (master) {
        _masterConnection = connection;
        MongoModernMessage.maxBsonObjectSize = resultDoc.maxBsonObjectSize;
        MongoModernMessage.maxMessageSizeBytes = resultDoc.maxMessageSizeBytes;
        MongoModernMessage.maxWriteBatchSize = resultDoc.maxWriteBatchSize;
      } */
      serverCapabilities.getParamsFromHello(hello!);
      //Todo
      /*   if (serverConfig.authenticationScheme == null &&
          resultDoc.saslSupportedMechs != null) {
        if (resultDoc.saslSupportedMechs!.contains('SCRAM-SHA-256')) {
          db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_256;
        } else if (resultDoc.saslSupportedMechs!.contains('SCRAM-SHA-1')) {
          db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
        }
      } */
    }
  }
}
