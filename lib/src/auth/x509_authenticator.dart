import 'package:mongo_dart/mongo_dart.dart'
    show
        Connection,
        Db,
        DbCommand,
        MongoDartError,
        MongoQueryMessage,
        keyCode,
        keyCodeName,
        keyErrmsg,
        keyOk;
import 'package:mongo_dart/src/auth/auth.dart';

import '../database/commands/authentication_commands/x509_command.dart';

class X509Authenticator extends Authenticator {
  X509Authenticator(this.username, this.db) : super();

  final String? username;
  Db db;
  static final String name = 'MONGODB-X509';

  @override
  Future authenticate(Connection connection) async {
    if (connection.serverCapabilities.supportsOpMsg) {
      return modernAuthenticate(connection);
    }
    return legacyAuthenticate(connection);
  }

  Future<void> legacyAuthenticate(Connection connection) async {
    var command = createMongoDbX509AuthenticationCommand(db, username);
    await db.executeDbCommand(command, connection: connection);
  }

  static DbCommand createMongoDbX509AuthenticationCommand(
      Db db, String? username) {
    var command = {
      'authenticate': 1,
      'mechanism': name,
      if (username != null && username.isNotEmpty) 'user': username,
    };

    return DbCommand(db.authSourceDb ?? db, DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NONE, 0, 0, command, null);
  }

  Future<void> modernAuthenticate(Connection connection) async {
    var command = X509Command(db.authSourceDb ?? db, name, username,
        connection: connection);
    var result = await command.execute();

    if (result[keyOk] == 0.0) {
      throw MongoDartError(result[keyErrmsg],
          mongoCode: result[keyCode],
          errorCode: result[keyCode] == null ? null : '${result[keyCode]}',
          errorCodeName: result[keyCodeName]);
    }
  }
}
