//part of mongo_dart;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/core/auth/auth.dart';
import 'package:sasl_scram/sasl_scram.dart' show UsernamePasswordCredential;

import '../../src/core/network/abstract/connection_base.dart';
import '../../src/database/mongo_database.dart';
import '../../src/topology/server.dart';

class MongoDbCRAuthenticator extends Authenticator {
  MongoDbCRAuthenticator(this.db, this.credentials) : super();

  static final String name = 'MONGODB-CR';

  final MongoDatabase db;
  final UsernamePasswordCredential credentials;

  @override
  Future authenticate(Server server, {ConnectionBase? connection}) {
    throw MongoDartError('Authentication no more used');
  }
/* 
  static DbCommand createMongoDbCrAuthenticationCommand(
      Db db, UsernamePasswordCredential credentials, String nonce) {
    var hashedPassword = crypto.md5
        .convert(
            '${credentials.username}:mongo:${credentials.password}'.codeUnits)
        .toString();
    var key = crypto.md5
        .convert('$nonce${credentials.username}$hashedPassword'.codeUnits)
        .toString();
    var selector = {
      'authenticate': 1,
      'user': credentials.username,
      'nonce': nonce,
      'key': key
    };
    return DbCommand(db.authSourceDb ?? db, DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NONE, 0, -1, selector, null);
  } */
}
