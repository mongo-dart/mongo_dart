//part of mongo_dart;
import 'package:crypto/crypto.dart' as crypto;
import 'package:mongo_dart/mongo_dart.dart'
    show Connection, Db, DbCommand, MongoQueryMessage;
import 'package:mongo_dart/src/auth/auth.dart';
import 'package:sasl_scram/sasl_scram.dart' show UsernamePasswordCredential;

class MongoDbCRAuthenticator extends Authenticator {
  MongoDbCRAuthenticator(this.db, this.credentials) : super();

  static final String name = 'MONGODB-CR';

  final Db db;
  final UsernamePasswordCredential credentials;

  @override
  Future authenticate(Connection connection) {
    return db.getNonce(connection: connection).then((msg) {
      var nonce = msg['nonce'];
      var command = createMongoDbCrAuthenticationCommand(
          db, credentials, nonce.toString());
      return db.executeDbCommand(command, connection: connection);
    }).then((res) => res['ok'] == 1);
  }

  static DbCommand createMongoDbCrAuthenticationCommand(
      Db db, UsernamePasswordCredential credentials, String nonce) {
    var hashed_password = crypto.md5
        .convert(
            '${credentials.username}:mongo:${credentials.password}'.codeUnits)
        .toString();
    var key = crypto.md5
        .convert('$nonce${credentials.username}$hashed_password'.codeUnits)
        .toString();
    var selector = {
      'authenticate': 1,
      'user': credentials.username,
      'nonce': nonce,
      'key': key
    };
    return DbCommand(db.authSourceDb ?? db, DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NONE, 0, -1, selector, null);
  }
}
