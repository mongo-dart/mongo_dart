part of mongo_dart;

class MongoDbCRAuthenticator extends Authenticator {
  @override
  static final String name = 'MONGODB-CR';

  final Db db;
  final UsernamePasswordCredential credentials;

  MongoDbCRAuthenticator(this.db, this.credentials);

  @override
  Future authenticate(_Connection connection) {
    return db.getNonce(connection: connection).then((msg) {
      var nonce = msg["nonce"];
//      nonce = 'acb5dde67bf24659';
      var command =
          createMongoDbCrAuthenticationCommand(db, credentials, nonce);
      return db.executeDbCommand(command, connection: connection);
    }).then((res) => res["ok"] == 1);
  }

  static DbCommand createMongoDbCrAuthenticationCommand(
      Db db, UsernamePasswordCredential credentials, String nonce) {
    var md5 = new MD5();
    md5.add("${credentials.username}:mongo:${credentials.password}".codeUnits);
    var hashed_password = new BsonBinary.from(md5.close()).hexString;
    md5 = new MD5();
    md5.add("${nonce}${credentials.username}${hashed_password}".codeUnits);
    var key = new BsonBinary.from(md5.close()).hexString;
    var selector = {
      'authenticate': 1,
      'user': credentials.username,
      'nonce': nonce,
      'key': key
    };
    return new DbCommand(db.authSourceDb ?? db, DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NONE, 0, -1, selector, null);
  }
}
