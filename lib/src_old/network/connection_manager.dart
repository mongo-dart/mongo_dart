//part of mongo_dart;

import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

import '../../mongo_dart_old.dart'
    show Db, DbCommand, ServerConfig, State, WriteConcern;
import '../../src/core/error/mongo_dart_error.dart';
import '../auth/auth.dart';
import '../database/commands/diagnostic_commands/server_status_command/server_status_command.dart';
import '../database/commands/diagnostic_commands/server_status_command/server_status_options.dart';
import '../database/commands/replication_commands/hello_command/hello_command.dart';
import '../database/commands/replication_commands/hello_command/hello_result.dart';
import '../database/message/mongo_modern_message.dart';
import '../database/message/mongo_response_message.dart';
import '../../src/utils/map_keys.dart';
import '../../src/core/message/abstract/mongo_message.dart';
import 'connection.dart';

class ConnectionManager {
  final _log = Logger('ConnectionManager');
  final Db db;
  final _connectionPool = <String, Connection>{};
  final replyCompleters = <int, Completer<MongoResponseMessage>>{};
  final sendQueue = Queue<MongoMessage>();
  Connection? _masterConnection;

  ConnectionManager(this.db);

  Connection? get masterConnection => _masterConnection;

  Connection get masterConnectionVerified {
    if (_masterConnection != null && !_masterConnection!.isClosed) {
      return _masterConnection!;
    } else {
      throw MongoDartError('No master connection');
    }
  }

  Future _connect(Connection connection) async {
    await connection.connect();
    var result = <String, Object?>{keyOk: 0.0};
    // As I couldn't set-up a pre 3.6 environment, I check not only for
    // a {ok: 0.0} but also for any other error
    try {
      var helloCommand = HelloCommand(db,
          username: connection.serverConfig.userName, connection: connection);
      result = await helloCommand.execute(skipStateCheck: true);
    } catch (e) {
      //Do nothing
    }
    if (result[keyOk] == 1.0) {
      var resultDoc = HelloResult(result);
      var master = resultDoc.isWritablePrimary;
      connection.isMaster = master;
      if (master) {
        _masterConnection = connection;
        MongoModernMessage.maxBsonObjectSize = resultDoc.maxBsonObjectSize;
        MongoModernMessage.maxMessageSizeBytes = resultDoc.maxMessageSizeBytes;
        MongoModernMessage.maxWriteBatchSize = resultDoc.maxWriteBatchSize;
      }
      connection.serverCapabilities.getParamsFromHello(resultDoc);
      if (db.authenticationScheme == null &&
          resultDoc.saslSupportedMechs != null) {
        if (resultDoc.saslSupportedMechs!.contains('SCRAM-SHA-256')) {
          db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_256;
        } else if (resultDoc.saslSupportedMechs!.contains('SCRAM-SHA-1')) {
          db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
        }
      }
    } else {
      var isMasterCommand = DbCommand.createIsMasterCommand(db);
      var replyMessage = await connection.query(isMasterCommand);
      if (replyMessage.documents == null || replyMessage.documents!.isEmpty) {
        throw MongoDartError('Empty reply message received');
      }
      var documents = replyMessage.documents!;
      if (documents.first[keyOk] == 0.0) {
        throw MongoDartError(documents.first[keyErrmsg]);
      }
      _log.fine(() => documents.first.toString());
      var master = documents.first['ismaster'] == true;
      connection.isMaster = master;
      if (master) {
        _masterConnection = connection;
        MongoModernMessage.maxBsonObjectSize =
            documents.first[keyMaxBsonObjectSize];
        MongoModernMessage.maxMessageSizeBytes =
            documents.first[keyMaxMessageSizeBytes];
        MongoModernMessage.maxWriteBatchSize =
            documents.first[keyMaxWriteBatchSize];
      }
      connection.serverCapabilities.getParamsFromIstMaster(documents.first);
    }

    if (db.authenticationScheme == null) {
      if ((connection.serverCapabilities.fcv?.compareTo('4.0') ?? -1) > -1) {
        db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_256;
      } else if (connection.serverCapabilities.maxWireVersion >= 3) {
        db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
      } else {
        db.authenticationScheme = AuthenticationScheme.MONGODB_CR;
      }
    }
    if (connection.serverConfig.userName == null) {
      _log.fine(() => '$db: ${connection.serverConfig.hostUrl} connected');
    } else {
      try {
        await db.authenticate(connection.serverConfig.userName!,
            connection.serverConfig.password ?? '',
            connection: connection);
        _log.fine(() => '$db: ${connection.serverConfig.hostUrl} connected');
      } catch (e) {
        /// Atlas does not currently support SHA_256
        if (e is MongoDartError &&
            e.mongoCode == 8000 &&
            e.errorCodeName == 'AtlasError' &&
            e.message.contains('SCRAM-SHA-256') &&
            db.authenticationScheme == AuthenticationScheme.SCRAM_SHA_256) {
          _log.warning(() => 'Atlas connection: SCRAM_SHA_256 not available, '
              'downgrading to SCRAM_SHA_1');
          db.authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
          try {
            await db.authenticate(connection.serverConfig.userName!,
                connection.serverConfig.password ?? '',
                connection: connection);
            _log.fine(
                () => '$db: ${connection.serverConfig.hostUrl} connected');
          } catch (e) {
            rethrow;
          }
        }
        if (connection == _masterConnection) {
          _masterConnection = null;
        }
        await connection.close();
        rethrow;
      }
    }
    return true;
  }

  Future<void> open(WriteConcern writeConcern) async {
    var connectionErrors = [];
    for (var hostUrl in _connectionPool.keys) {
      var connection = _connectionPool[hostUrl];
      if (connection == null) {
        connectionErrors
            .add('Connection in pool for server "$hostUrl" has not been found');
        continue;
      }
      try {
        await _connect(connection);
      } catch (e) {
        connectionErrors.add(e);
      }
    }
    if (connectionErrors.isNotEmpty) {
      if (_masterConnection == null) {
        for (var error in connectionErrors) {
          _log.severe('$error');
        }
        // Simply returns the first exception to be more compatible
        // with previous error management.
        throw connectionErrors.first;
      } else {
        for (var error in connectionErrors) {
          _log.warning('$error');
        }
      }
    }
    if (_masterConnection == null) {
      throw MongoDartError('No Primary found');
    }
    if (unfilled(db.databaseName)) {
      throw MongoDartError('Database name not specified');
    }
    db.state = State.open;

    if (_masterConnection!.serverCapabilities.supportsOpMsg) {
      await ServerStatusCommand(db,
              serverStatusOptions: ServerStatusOptions.instance)
          .updateServerStatus(db.masterConnection);
    }
  }

  Future close() async {
    while (sendQueue.isNotEmpty) {
      masterConnection?.sendBuffer();
    }
    sendQueue.clear();

    _masterConnection == null;

    for (var hostUrl in _connectionPool.keys) {
      var connection = _connectionPool[hostUrl];
      _log.fine(() => '$db: ${connection?.serverConfig.hostUrl} closed');
      await connection?.close();
    }
    replyCompleters.clear();
  }

  void addConnection(ServerConfig serverConfig) {
    var connection = Connection(this, serverConfig);
    _connectionPool[serverConfig.hostUrl] = connection;
  }

  Connection? removeConnection(Connection connection) {
    connection.close();
    if (connection.isMaster) {
      _masterConnection = null;
    }
    return _connectionPool.remove(connection.serverConfig.hostUrl);
  }
}
