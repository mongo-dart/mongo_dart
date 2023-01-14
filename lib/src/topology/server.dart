import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/core/error/connection_exception.dart';
import 'package:mongo_dart/src/settings/connection_pool_settings.dart';

import '../command/base/operation_base.dart';
import '../core/info/server_capabilities.dart';
import '../core/info/server_config.dart';
import '../core/info/server_status.dart';
import '../core/message/abstract/section.dart';
import '../core/message/mongo_modern_message.dart';
import '../core/network/connection_pool.dart';
import '../session/client_session.dart';

enum ServerState { closed, connected }

class Server {
  Server(
      this.mongoClient, this.serverConfig, ConnectionPoolSettings poolSettings)
      : connectionPool = ConnectionPool(serverConfig, poolSettings);

  final Logger log = Logger('Server');
  final MongoClient mongoClient;
  final ServerConfig serverConfig;
  final ServerCapabilities serverCapabilities = ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();
  final ConnectionPool connectionPool;

  ServerState state = ServerState.closed;
  HelloResult? hello;
  int lastHelloExecutionMS = 0;

  bool get isAuthenticated => serverConfig.isAuthenticated;
  bool get isConnected => state == ServerState.connected;

  bool get isStandalone => serverCapabilities.isStandalone;
  bool get isReplicaSet => serverCapabilities.isReplicaSet;
  bool get isShardedCluster => serverCapabilities.isShardedCluster;

  bool get isWritablePrimary => hello?.isWritablePrimary ?? false;
  bool get isReadOnlyMode => hello?.readOnly ?? true;

  /// Return the server url (no scheme)
  /// Url can be considered correct only after receiving the first hello message
  String get url => hello?.me == null ? serverConfig.hostUrl : hello!.me!;

  /// Comparison operator.
  /// Note, it is correct only after the first hello message (connection)
  /// Do not add to containers before that.
  @override
  bool operator ==(other) => other is Server && url == other.url;

  /// Hash Code.
  /// Note, it is correct only after the first hello message (connection)
  /// Do not add to containers before that.
  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'Server -> $url';

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

/* 
  @Deprecated('To be substituted by executeCommand')
  Future<Map<String, dynamic>> executeMessage(
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
 */

  Future<MongoDocument> executeCommand(Command command,
      {ClientSession? session}) async {
    if (state != ServerState.connected) {
      throw MongoDartError('Server is not is not connected. $state');
    }
    var isImplicitSession = session == null;

    var connection = await connectionPool.getAvailableConnection();

    session ??= ClientSession(mongoClient);
    //session.serverSession ??= mongoClient.serverSessionPool.acquireSession();
    //session.serverSession!.lastUse = DateTime.now();
    //command[keyLsid] = session.serverSession!.toMap;
    session.prepareCommand(command);

    print(command);

    var response = await connection.execute(MongoModernMessage(command));
    if (isImplicitSession) {
      await session.endSession();
    }

    var section = response.sections.firstWhere((Section section) =>
        section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }

  Future<void> refreshStatus() => _runHello();

  Future<void> _runHello() async {
    Map<String, dynamic> result = {keyOk: 0.0};
    try {
      var helloCommand = HelloCommand(this, username: serverConfig.userName);
      var actualTimeMS = DateTime.now().millisecondsSinceEpoch;
      try {
        result = await helloCommand.execute();
      } catch (error) {
        print(error);
        rethrow;
      }
      lastHelloExecutionMS =
          DateTime.now().millisecondsSinceEpoch - actualTimeMS;
    } on MongoDartError catch (err) {
      //Do nothing
      print('Passed by _runHello() - Error ${err.message}');
    }
    if (result[keyOk] == 1.0) {
      hello = HelloResult(result);
      if (isWritablePrimary) {
        MongoModernMessage.maxBsonObjectSize = hello!.maxBsonObjectSize;
        MongoModernMessage.maxMessageSizeBytes = hello!.maxMessageSizeBytes;
        MongoModernMessage.maxWriteBatchSize = hello!.maxWriteBatchSize;
      }
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
