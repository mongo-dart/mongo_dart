part of mongo_dart;

class MongoDbCRAuthenticator extends Authenticator {
  static final String name = 'MONGODB-CR';

  final Db db;
  final UsernamePasswordCredential credentials;

  MongoDbCRAuthenticator(this.db, this.credentials);

  @override
  Future authenticate(_Connection connection) {
    return db.getNonce(connection: connection).then((msg) {
      var nonce = msg["nonce"];
      var command =
          createMongoDbCrAuthenticationCommand(db, credentials, nonce);
      return db.executeDbCommand(command, connection: connection);
    }).then((res) => res["ok"] == 1);
  }

  static DbCommand createMongoDbCrAuthenticationCommand(
      Db db, UsernamePasswordCredential credentials, String nonce) {
    var hashed_password = crypto.md5
        .convert(
            "${credentials.username}:mongo:${credentials.password}".codeUnits)
        .toString();
    var key = crypto.md5
        .convert("$nonce${credentials.username}$hashed_password".codeUnits)
        .toString();
    var selector = {
      'authenticate': 1,
      'user': credentials.username,
      'nonce': nonce,
      'key': key
    };
    return new DbCommand(
        db.authSourceDb ?? db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NONE,
        0,
        -1,
        selector,
        null);
  }
}
