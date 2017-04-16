part of mongo_dart;

class ClientFirst extends SaslStep {
  String clientFirstMessageBare;
  UsernamePasswordCredential credential;
  String rPrefix;

  ClientFirst(Uint8List bytesToSendToServer, this.credential,
      this.clientFirstMessageBare, this.rPrefix) {
    this.bytesToSendToServer = bytesToSendToServer;
    isComplete = false;
  }

  @override
  SaslStep transition(
      SaslConversation conversation, List<int> bytesReceivedFromServer) {
    String serverFirstMessage = UTF8.decode(bytesReceivedFromServer);

    Map decodedMessage = parsePayload(serverFirstMessage);

    String r = decodedMessage['r'];
    if (r == null || !r.startsWith(rPrefix)) {
      throw new MongoDartError("Server sent an invalid nonce.");
    }

    var s = decodedMessage['s'];
    var i = int.parse(decodedMessage['i']);

    final String gs2Header = 'n,,';
    String encodedHeader = BASE64.encode(UTF8.encode(gs2Header));
    var channelBinding = 'c=$encodedHeader';
    var nonce = 'r=$r';
    var clientFinalMessageWithoutProof = '$channelBinding,$nonce';

    var passwordDigest =
        md5DigestPassword(credential.username, credential.password);
    var salt = BASE64.decode(s);

    var saltedPassword = hi(passwordDigest, salt, i);
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
    var sha1 = crypto.sha1;
    var hmac = new crypto.Hmac(sha1, data);
    hmac.convert(UTF8.encode(key));
    return new Uint8List.fromList(hmac.convert(UTF8.encode(key)).bytes);
  }

  static Uint8List h(Uint8List data) {
    return new Uint8List.fromList(crypto.sha1.convert(data).bytes);
  }

  static String md5DigestPassword(username, password) {
    return crypto.md5
        .convert(UTF8.encode('$username:mongo:$password'))
        .toString();
  }

  static Uint8List xor(Uint8List a, Uint8List b) {
    var result = [];

    if (a.length > b.length) {
      for (var i = 0; i < b.length; i++) {
        result.add(a[i] ^ b[i]);
      }
    } else {
      for (var i = 0; i < a.length; i++) {
        result.add(a[i] ^ b[i]);
      }
    }

    return new Uint8List.fromList(result);
  }

  static Uint8List hi(String password, Uint8List salt, int iterations) {
    var digest = (msg) {
      var hmac = new crypto.Hmac(crypto.sha1, password.codeUnits);
      return new Uint8List.fromList(hmac.convert(msg).bytes);
    };

    Uint8List newSalt =
        new Uint8List.fromList(new List.from(salt)..addAll([0, 0, 0, 1]));

    var ui = digest(newSalt);
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
    isComplete = false;
  }

  @override
  SaslStep transition(
      SaslConversation conversation, List<int> bytesReceivedFromServer) {
    Map decodedMessage = parsePayload(UTF8.decode(bytesReceivedFromServer));
    var serverSignature = BASE64.decode(decodedMessage['v']);

    if (!const IterableEquality().equals(serverSignature64, serverSignature)) {
      throw new MongoDartError("Server signature was invalid.");
    }

    return new CompletedStep();
  }
}

class CompletedStep extends SaslStep {
  CompletedStep() {
    this.bytesToSendToServer = new Uint8List(0);
    isComplete = true;
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
    var r = randomStringGenerator.generate(20); // TODO Change this

    var nonce = 'r=$r';

    var clientFirstMessageBare = '$username,$nonce';
    var clientFirstMessage = '$gs2Header$clientFirstMessageBare';

    return new ClientFirst(
        UTF8.encode(clientFirstMessage), credential, clientFirstMessageBare, r);
  }

  String prepUsername(String username) =>
      username.replaceAll('=', '=3D').replaceAll(',', '=2C');

  @override
  String get name => ScramSha1Authenticator.name;
}

class ScramSha1Authenticator extends SaslAuthenticator {
  static String name = 'SCRAM-SHA-1';

  ScramSha1Authenticator(UsernamePasswordCredential credential, Db db)
      : super(
            new ScramSha1Mechanism(
                credential, new CryptoStrengthStringGenerator()),
            db) {
    this.db = db;
  }
}
