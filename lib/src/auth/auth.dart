part of mongo_dart;

enum AuthenticationScheme { MONGODB_CR, SCRAM_SHA_1 }

abstract class Authenticator {
  static String name;

  Future authenticate(_Connection connection);
}

Authenticator createAuthenticator(AuthenticationScheme authenticationScheme,
    Db db, UsernamePasswordCredential credentials) {
  switch (authenticationScheme) {
    case AuthenticationScheme.MONGODB_CR:
      return new MongoDbCRAuthenticator(db, credentials);
    case AuthenticationScheme.SCRAM_SHA_1:
      return new ScramSha1Authenticator(credentials, db);
    default:
      throw new MongoDartError("Authenticator wasn't specified");
  }
}

class UsernamePasswordCredential {
  String username;
  String password; // TODO: Encrypt this to secureString
}

abstract class RandomStringGenerator {
  static const String allowedCharacters =
      '!"#\'\$%&()*+-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

  String generate(int length);
}

class CryptoStrengthStringGenerator extends RandomStringGenerator {
  @override
  String generate(int length) {
    var random = new Random.secure();
    var allowedCodeUnits = RandomStringGenerator.allowedCharacters.codeUnits;

    int max = allowedCodeUnits.length - 1;

    List<int> randomString = [];

    for (int i = 0; i < length; ++i) {
      randomString.add(allowedCodeUnits.elementAt(random.nextInt(max)));
    }

    return new String.fromCharCodes(randomString);
  }
}

Map<String, String> parsePayload(String payload) {
  var dict = {};
  var parts = payload.split(',');

  for (var i = 0; i < parts.length; i++) {
    var key = parts[i][0];
    var value = parts[i].substring(2);
    dict[key] = value;
  }

  return dict;
}
