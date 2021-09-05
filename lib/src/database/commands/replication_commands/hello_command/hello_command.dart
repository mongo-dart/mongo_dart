import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:vy_string_utils/vy_string_utils.dart';
import 'hello_options.dart';
import 'hello_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

var _command = <String, Object>{keyHello: 1};

/// The Hello command takes the following form:
///
/// `db.runCommand( { hello: 1 } )`
///
/// The hello command accepts optional fields saslSupportedMechs:
/// <db.user> to return an additional field hello.saslSupportedMechs
/// in its result and comment <String> to add a log comment associated
/// with the command.
///
/// `db.runCommand( { hello: 1, saslSupportedMechs: "<db.username>",
/// comment: <String> } )`
class HelloCommand extends CommandOperation {
  HelloCommand(Db db,
      {String? username,
      HelloOptions? helloOptions,
      Map<String, Object>? rawOptions,
      Connection? connection})
      : super(db, <String, Object>{...?helloOptions?.options, ...?rawOptions},
            command: {
              ..._command,
              if (filled(username))
                keySaslSupportedMechs: '${db.databaseName}.$username'
            },
            connection: connection);

  Future<HelloResult> executeDocument() async {
    var result = await super.execute();
    return HelloResult(result);
  }

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
