import 'dart:convert';

import 'package:crypto/crypto.dart' show md5;
import 'package:mongo_dart/src/core/auth/scram_sha1_authenticator.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';
import 'package:sasl_scram/sasl_scram.dart'
    show SaslMechanism, UsernamePasswordCredential;
import 'package:mongo_dart/mongo_dart_old.dart'
    show
        SaslContinueCommand,
        SaslStartCommand,
        SaslStartOptions,
        keyCode,
        keyCodeName,
        keyErrmsg,
        keyOk;
import 'package:mongo_dart/src/core/auth/auth.dart';

import '../../database/mongo_database.dart';
import '../error/mongo_dart_error.dart';
import '../network/abstract/connection_base.dart';
import '../../topology/server.dart';

abstract class SaslAuthenticator extends Authenticator {
  SaslAuthenticator(this.mechanism, this.db) : super();

  SaslMechanism mechanism;
  MongoDatabase db;

  @override
  Future authenticate(Server server, {ConnectionBase? connection}) async {
    return modernAuthenticate(server, connection: connection);
  }

  @Deprecated('No More Used')
  Future legacyAuthenticate(ConnectionBase connection) async {
    /*  var currentStep = mechanism.initialize(specifyUsername: true);

    var command = DbCommand.createSaslStartCommand(
        db.authSourceDb ?? db, mechanism.name, currentStep.bytesToSendToServer);

    while (true) {
      Map<String, dynamic> result;

      result = await db.executeDbCommand(command, connection: connection);

      if (result['done'] == true && currentStep.isComplete) {
        break;
      }

      var payload = result['payload'];

      var payloadAsBytes = base64.decode(payload.toString());

      if (mechanism.name == ScramSha1Authenticator.name) {
        currentStep = currentStep.transition(payloadAsBytes,
            passwordDigestResolver: (UsernamePasswordCredential credential) =>
                md5
                    .convert(utf8.encode(
                        '${credential.username}:mongo:${credential.password}'))
                    .toString());
      } else {
        currentStep = currentStep.transition(payloadAsBytes);
      }

      var conversationId = result['conversationId'] as int;

      command = DbCommand.createSaslContinueCommand(db.authSourceDb ?? db,
          conversationId, currentStep.bytesToSendToServer);
    } */
  }

  Future modernAuthenticate(Server server, {ConnectionBase? connection}) async {
    var currentStep = mechanism.initialize(specifyUsername: true);

    CommandOperation command = SaslStartCommand(
        db.authSourceDb ?? db, mechanism.name, currentStep.bytesToSendToServer,
        saslStartOptions: SaslStartOptions(), connection: connection);

    while (true) {
      Map<String, dynamic> result;

      result = await command.execute(server);

      if (result[keyOk] == 0.0) {
        throw MongoDartError(result[keyErrmsg],
            mongoCode: result[keyCode],
            errorCode: result[keyCode] == null ? null : '${result[keyCode]}',
            errorCodeName: result[keyCodeName]);
      }
      if (result['done'] == true) {
        break;
      }

      var payload = result['payload'];

      var payloadAsBytes = base64.decode(payload.toString());

      if (mechanism.name == ScramSha1Authenticator.name) {
        currentStep = currentStep.transition(payloadAsBytes,
            passwordDigestResolver: (UsernamePasswordCredential credential) =>
                md5
                    .convert(utf8.encode(
                        '${credential.username}:mongo:${credential.password}'))
                    .toString());
      } else {
        currentStep = currentStep.transition(payloadAsBytes);
      }

      var conversationId = result['conversationId'] as int;

      command = SaslContinueCommand(db.authSourceDb ?? db, conversationId,
          currentStep.bytesToSendToServer,
          connection: connection);
    }
  }
}
