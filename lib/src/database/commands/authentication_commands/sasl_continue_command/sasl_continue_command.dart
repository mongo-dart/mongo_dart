import 'dart:convert';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'sasl_continue_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class SaslContinueCommand extends CommandOperation {
  SaslContinueCommand(Db db, int conversationId, Uint8List payload,
      {SaslContinueOptions? saslContinueOptions,
      Map<String, Object>? rawOptions,
      Connection? connection})
      : super(db,
            <String, Object>{...?saslContinueOptions?.options, ...?rawOptions},
            command: <String, Object>{
              keySaslContinue: 1,
              keyConversationId: conversationId,
              keyPayload: base64.encode(payload)
            },
            connection: connection);

  /*  @override
  Future<Map<String, Object?>> execute({bool skipStateCheck = false}) async =>
      super.execute(skipStateCheck: true); */
  @override
  Future<Map<String, Object?>> execute({bool skipStateCheck = false}) async {
    final db = this.db;

    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    connection ??= db.masterConnectionAnyState;

    var response = await connection!.executeModernMessage(message);

    var section = response.sections.firstWhere((Section _section) =>
        _section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }
}
