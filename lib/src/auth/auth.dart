//part of mongo_dart;
import 'package:mongo_dart/mongo_dart.dart' show Connection, Db, MongoDartError;
import 'package:mongo_dart/src/auth/mongodb_x509_authenticator.dart';
import 'package:sasl_scram/sasl_scram.dart' show UsernamePasswordCredential;

import 'mongodb_cr_authenticator.dart';
import 'scram_sha1_authenticator.dart';
import 'scram_sha256_authenticator.dart';

// ignore: constant_identifier_names
enum AuthenticationScheme { MONGODB_CR, SCRAM_SHA_1, SCRAM_SHA_256, X509 }

abstract class Authenticator {
  Authenticator();

  factory Authenticator.create(AuthenticationScheme authenticationScheme, Db db,
      UsernamePasswordCredential credentials) {
    switch (authenticationScheme) {
      case AuthenticationScheme.MONGODB_CR:
        return MongoDbCRAuthenticator(db, credentials);
      case AuthenticationScheme.SCRAM_SHA_1:
        return ScramSha1Authenticator(credentials, db);
      case AuthenticationScheme.SCRAM_SHA_256:
        return ScramSha256Authenticator(credentials, db);
      case AuthenticationScheme.X509:
        return MongoDbX509Authenticator(credentials.username, db);
      default:
        throw MongoDartError("Authenticator wasn't specified");
    }
  }

  static String? name;

  Future authenticate(Connection connection);
}

abstract class RandomStringGenerator {
  static const String allowedCharacters = '!"#\'\$%&()*+-./0123456789:;<=>?@'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

  String generate(int length);
}

Map<String, String> parsePayload(String payload) {
  var dict = <String, String>{};
  var parts = payload.split(',');

  for (var i = 0; i < parts.length; i++) {
    var key = parts[i][0];
    var value = parts[i].substring(2);
    dict[key] = value;
  }

  return dict;
}
