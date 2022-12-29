import 'dart:convert';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/core/network/abstract/connection_base.dart';

import '../../../database/mongo_database.dart';
import '../../../topology/server.dart';

class SaslStartCommand extends CommandOperation {
  SaslStartCommand(MongoDatabase db, String mechanism, Uint8List payload,
      {SaslStartOptions? saslStartOptions,
      Map<String, Object>? rawOptions,
      ConnectionBase? connection})
      : super(db, <String, dynamic>{
          keySaslStart: 1,
          keyMechanism: mechanism,
          keyPayload: base64.encode(payload)
        }, <String, dynamic>{
          ...?saslStartOptions?.options,
          ...?rawOptions
        });

  /*  @override
  Future<Map<String, Object?>> execute({bool skipStateCheck = false}) async =>
      super.execute(skipStateCheck: true); */

  @override
  Future<Map<String, Object?>> executeOnServer(Server server,
      {ConnectionBase? connection, bool skipStateCheck = false}) async {
    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    return server.executeMessage(message);
  }
}
