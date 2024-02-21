//part of mongo_dart;
import 'package:mongo_dart/mongo_dart.dart'
    show Connection, Db, DbCommand, MongoQueryMessage;
import 'package:mongo_dart/src/auth/auth.dart';

class MongoDbX509Authenticator extends Authenticator {
  MongoDbX509Authenticator(this.username, this.db) : super();

  static final String name = 'MONGODB-X509';

  final Db db;
  final String? username;

  @override
  Future authenticate(Connection connection) {
    var command = createMongoDbX509AuthenticationCommand(db, username);
    return db
        .executeDbCommand(command, connection: connection)
        .then((res) => res['ok'] == 1);
  }

  static DbCommand createMongoDbX509AuthenticationCommand(
      Db db, String? username) {
    var selector = {
      'authenticate': 1,
      'mechanism': name,
      if (username != null && username.isNotEmpty) 'user': username,
    };

    return DbCommand(db.authSourceDb ?? db, DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NONE, 0, 0, selector, null);
  }
}
