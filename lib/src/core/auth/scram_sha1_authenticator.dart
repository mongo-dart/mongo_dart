import 'package:crypto/crypto.dart' as crypto;
import 'package:sasl_scram/sasl_scram.dart'
    show
        ScramMechanism,
        UsernamePasswordCredential,
        CryptoStrengthStringGenerator;

import '../../database/base/mongo_database.dart';
import 'sasl_authenticator.dart';

class ScramSha1Authenticator extends SaslAuthenticator {
  static String name = 'SCRAM-SHA-1';

  ScramSha1Authenticator(
      UsernamePasswordCredential credential, MongoDatabase db)
      : super(
            ScramMechanism(
                'SCRAM-SHA-1', // Optionally choose hash method from a list provided by the server
                crypto.sha1,
                credential,
                CryptoStrengthStringGenerator()),
            db) {
    this.db = db;
  }
}
