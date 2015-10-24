part of mongo_dart;

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

abstract class SaslAuthenticator extends Authenticator {
  SaslMechanism mechanism;
  Db db;

  SaslAuthenticator(this.mechanism, this.db);

  @override
  Future authenticate(_Connection connection) async {
    var conversation = new SaslConversation(connection);

    var currentStep = mechanism.initialize(connection);

    var command = DbCommand.createSaslStartCommand(
        db.authSourceDb ?? db, mechanism.name, currentStep.bytesToSendToServer);

    while (true) {
      Map result;

      result = await db.executeDbCommand(command, connection: connection);

      if (result['done'] == true && currentStep.isComplete) {
        break;
      }

      var payload = result['payload'];

      var payloadAsBytes = BASE64.decode(payload);

      currentStep = currentStep.transition(conversation, payloadAsBytes);


      var conversationId = result['conversationId'];

      command = DbCommand.createSaslContinueCommand(
          db.authSourceDb ?? db, conversationId, currentStep.bytesToSendToServer);
    }
  }
}
