import 'dart:convert';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import '../../../core/network/abstract/connection_base.dart';
import '../../../database/db.dart';
import '../../../topology/server.dart';
import 'sasl_continue_options.dart';

class SaslContinueCommand extends CommandOperation {
  SaslContinueCommand(Db db, int conversationId, Uint8List payload,
      {SaslContinueOptions? saslContinueOptions,
      Map<String, Object>? rawOptions,
      ConnectionBase? connection})
      : super(db,
            <String, Object>{...?saslContinueOptions?.options, ...?rawOptions},
            command: <String, Object>{
              keySaslContinue: 1,
              keyConversationId: conversationId,
              keyPayload: base64.encode(payload)
            },
            connection: connection);

  @override
  Future<Map<String, Object?>> execute(Server server,
      {ConnectionBase? connection}) async {
    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    return server.executeModernMessage(message, connection: connection);
  }
}