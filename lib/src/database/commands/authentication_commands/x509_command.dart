import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';

class X509Command extends CommandOperation {
  X509Command(Db db, String mechanism, String? username,
      {Map<String, Object>? rawOptions, Connection? connection})
      : super(db, <String, Object>{...?rawOptions},
            command: <String, Object>{
              keyAuthenticate: 1,
              keyMechanism: mechanism,
              if (username != null && username.isNotEmpty) keyUser: username
            },
            connection: connection);

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
