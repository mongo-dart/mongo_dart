part of mongo_dart;

abstract class Authenticator {
  String name;
  Future authenticate(_Connection connection);
}

abstract class SaslMechanism {
  String get name;

  SaslStep initialize(_Connection connection);
}

abstract class SaslStep {
  Uint8List bytesToSendToServer;
  bool isComplete;
  SaslStep transition(
      SaslConversation conversation, List<int> bytesReceivedFromServer);
}

class SaslConversation {
  _Connection connection;

  SaslConversation(this.connection);
}

class SaslAuthenticator extends Authenticator {
  SaslMechanism mechanism;
  Db db;

  SaslAuthenticator(this.mechanism, this.db);

  @override
  Future authenticate(_Connection connection) async {
    var conversation = new SaslConversation(connection);

    var currentStep = mechanism.initialize(connection);

    while (true) {
      Map result;

      var command = DbCommand.createSaslStartCommand(
          db, mechanism.name, currentStep.bytesToSendToServer);
      result = await db.executeDbCommand(command, connection: connection);

      if (result['done'] == true && currentStep.isComplete) {
        break;
      }

      var payload = UTF8.encode(result['payload']);
      currentStep = currentStep.transition(conversation, payload);

      if (result['done'] == false && currentStep.isComplete) {
        break;
      }

      var conversationId = int.parse(result['conversationId']);
      command = DbCommand.createSaslContinueCommand(
          db, conversationId, currentStep.bytesToSendToServer);
    }
  }
}

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

class ClientFirst extends SaslStep {
  String clientFirstMessageBare;
  UsernamePasswordCredential credential;
  String rPrefix;

  bool get isComplete => false;

  ClientFirst(Uint8List bytesToSendToServer, this.credential,
      this.clientFirstMessageBare, this.rPrefix) {
    this.bytesToSendToServer = bytesToSendToServer;
  }

  @override
  SaslStep transition(
      SaslConversation conversation, List<int> bytesReceivedFromServer) {
    var encoding = new Utf8Codec();

    String serverFirstMessage = encoding.decode(bytesReceivedFromServer);
    Map decodedMessage = parsePayload(serverFirstMessage);

    String r = decodedMessage['r'];
    if (!r.startsWith(rPrefix)) {
      throw new MongoDartError("Server sent an invalid nonce.");
    }

    var s = decodedMessage['s'];
    int i = int.parse(decodedMessage['i']);

    final String gs2Header = 'n,,';
    String encodedHeader = BASE64.encode(encoding.encode(gs2Header));
    var channelBinding = 'c=$encodedHeader';
    var nonce = 'r=$r';
    var clientFinalMessageWithoutProof = '$channelBinding,$nonce';

    var passwordDigest =
        md5DigestPassword(credential.username, credential.password);
    var saltedPassword = hi(passwordDigest, BASE64.decode(s), i);

    var clientKey = computeHMAC(saltedPassword, 'Client Key');
    var storedKey = h(clientKey);
    var authMessage =
        '$clientFirstMessageBare,$serverFirstMessage,$clientFinalMessageWithoutProof';
    var clientSignature = computeHMAC(storedKey, authMessage);
    var clientProof = xor(clientKey, clientSignature);
    var serverKey = computeHMAC(saltedPassword, 'Server Key');
    var serverSignature = computeHMAC(serverKey, authMessage);

    var base64clientProof = BASE64.encode(clientProof);
    var proof = 'p=$base64clientProof';
    var clientFinalMessage = '$clientFinalMessageWithoutProof,$proof';

    return new ClientLast(UTF8.encode(clientFinalMessage), serverSignature);
  }

  static Uint8List computeHMAC(Uint8List data, String key) {
    var sha1 = new SHA1();
    var hmac = new HMAC(sha1, data);
    hmac.add(UTF8.encode(key));
    return hmac.close();
  }

  static Uint8List h(Uint8List data) {
    var sha1 = new SHA1();
    sha1.add(data);
    return sha1.close();
  }

  static String md5DigestPassword(username, password) {
    var md5 = new MD5()..add(UTF8.encode('$username:mongo:$password'));
    List<int> bytes = md5.close();
    return CryptoUtils.bytesToHex(bytes);
  }

  static Uint8List xor(Uint8List a, Uint8List b) {
    var result = new Uint8List(a.length);

    if (a.length > b.length) {
      for (var i = 0; i < b.length; i++) {
        result.add(a[i] ^ b[i]);
      }
    } else {
      for (var i = 0; i < a.length; i++) {
        result.add(a[i] ^ b[i]);
      }
    }

    return result;
  }

  static Uint8List hi(String password, Uint8List salt, int iterations) {
    List<int> passwordDigest = [];

    var digest = (msg) {
      var hmac = new HMAC(new SHA1(), passwordDigest);
      hmac.add(msg);
      return new Uint8List.fromList(hmac.digest);
    };

    salt.addAll([0, 0, 0, 1]);

    var ui = digest(salt);
    var u1 = ui;

    for (var i = 0; i < iterations - 1; i++) {
      u1 = digest(u1);
      ui = xor(ui, u1);
    }

    return ui;
  }
}

class ClientLast extends SaslStep {
  Uint8List serverSignature64;

  ClientLast(Uint8List bytesToSendToServer, this.serverSignature64) {
    this.bytesToSendToServer = bytesToSendToServer;
  }

  bool get complete => false;

  @override
  SaslStep transition(
      SaslConversation conversation, List<int> bytesReceivedFromServer) {
    Map decodedMessage = parsePayload(UTF8.decode(bytesReceivedFromServer));
    var serverSignature = BASE64.decode(decodedMessage['v']);

    if (!const ListEquality().equals(serverSignature64, serverSignature)) {
      throw new MongoDartError("Server signature was invalid.");
    }

    return new CompletedStep();
  }
}

class CompletedStep extends SaslStep {
  bool get complete => true;

  CompletedStep() {
    this.bytesToSendToServer = [];
  }

  @override
  SaslStep transition(
      SaslConversation conversation, List<int> bytesReceivedFromServer) {
    throw new MongoDartError("Sasl conversation has completed");
  }
}

class ScramSha1Mechanism extends SaslMechanism {
  final UsernamePasswordCredential credential;
  final RandomStringGenerator randomStringGenerator;

  ScramSha1Mechanism(this.credential, this.randomStringGenerator);

  @override
  SaslStep initialize(_Connection connection) {
    if (connection == null) throw new ArgumentError("Connection can't be null");

    final String gs2Header = 'n,,';
    var username = 'n=${prepUsername(credential.username)}';
    var r = randomStringGenerator.generate(20, ""); // TODO Change this
    var nonce = 'r=$r';

    var clientFirstMessageBare = '$username,$nonce';
    var clientFirstMessage = '$gs2Header$clientFirstMessageBare';

    return new ClientFirst(
        UTF8.encode(clientFirstMessage), credential, clientFirstMessageBare, r);
  }

  String prepUsername(String username) =>
      username.replaceAll('=', '=3D').replaceAll(',', '=2C');

  String generateRandomString() {
    const String legalCharacters =
        '!"#\'\$%&()*+-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

    return randomStringGenerator.generate(20, legalCharacters);
  }

  @override
  String get name => ScramSha1Authenticator.SCRAM;
}

class ScramSha1Authenticator extends SaslAuthenticator {
  static final String SCRAM = 'SCRAM-SHA-1';

  @override
  String get name => "SCRAM-SHA-1";

  ScramSha1Authenticator(UsernamePasswordCredential credential, Db db)
      : super(new ScramSha1Mechanism(credential, new WeakRandomStringGenerator()),
            db) {
    this.db = db;
  }
}
