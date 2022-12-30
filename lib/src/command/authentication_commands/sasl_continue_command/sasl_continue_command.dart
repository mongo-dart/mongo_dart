import 'dart:convert';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import '../../../core/network/abstract/connection_base.dart';
import '../../../database/document_types.dart';
import '../../../database/base/mongo_database.dart';
import '../../../topology/server.dart';
import 'sasl_continue_options.dart';

class SaslContinueCommand extends CommandOperation {
  SaslContinueCommand(MongoDatabase db, int conversationId, Uint8List payload,
      {SaslContinueOptions? saslContinueOptions,
      Map<String, Object>? rawOptions,
      ConnectionBase? connection})
      : super(db, <String, dynamic>{
          keySaslContinue: 1,
          keyConversationId: conversationId,
          keyPayload: base64.encode(payload)
        }, <String, dynamic>{
          ...?saslContinueOptions?.options,
          ...?rawOptions
        });

  @override
  Future<MongoDocument> executeOnServer(Server server,
      {ConnectionBase? connection}) async {
    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    return server.executeMessage(message);
  }
}
