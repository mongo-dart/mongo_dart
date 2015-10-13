part of mongo_dart;

class UsernamePasswordCredential {
  String username;
  String password; // TODO: Encrypt this to secureString
  String source; // Database name
}

abstract class RandomStringGenerator {
  String generate(int length, String legalCharacters);
}

class WeakRandomStringGenerator extends RandomStringGenerator {
  @override
  String generate(int length, String legalCharacters) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });

    return new String.fromCharCodes(codeUnits);
  }
}

Map<String, String> parsePayload(String payload) {
  var dict = {};
  var parts = payload.split(',');

  for (var i = 0; i < parts.length; i++) {
    var valueParts = parts[i].split('=');
    dict[valueParts[0]] = valueParts[1];
  }

  return dict;
}
