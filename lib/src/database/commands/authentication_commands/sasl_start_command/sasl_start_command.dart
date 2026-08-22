import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';

class SaslStartCommand extends CommandOperation {
  SaslStartCommand(Db db, String mechanism, Uint8List payload,
      {SaslStartOptions? saslStartOptions,
      Map<String, Object>? rawOptions,
      Connection? connection})
      : super(
            db, <String, Object>{...?saslStartOptions?.options, ...?rawOptions},
            command: <String, Object>{
              keySaslStart: 1,
              keyMechanism: mechanism,
              // The SASL payload is BinData in the wire protocol. mongod also
              // accepts a base64 string, but a strict implementation does not:
              // Azure Cosmos DB for MongoDB (vCore) answers `Failed to parse:
              // error at key: "payload": unexpected element type: String,
              // expected: Binary` and authentication can never complete.
              keyPayload: BsonBinary.from(payload)
            },
            connection: connection);

  /*  @override
  Future<Map<String, dynamic>> execute({bool skipStateCheck = false}) async =>
      super.execute(skipStateCheck: true); */

  @override
  Future<Map<String, dynamic>> execute({bool skipStateCheck = false}) async {
    final db = this.db;

    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    connection ??= db.masterConnectionAnyState;

    var response = await connection!.executeModernMessage(message);

    var section = response.sections.firstWhere((Section section) =>
        section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }
}
