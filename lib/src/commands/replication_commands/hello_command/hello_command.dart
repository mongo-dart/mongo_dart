import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/base/simple_command.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

import '../../../database/mongo_database.dart';
import '../../../topology/abstract/topology.dart';

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
class HelloCommand extends SimpleCommand {
  HelloCommand(Topology topology,
      {MongoDatabase? db,
      String? username,
      HelloOptions? helloOptions,
      Map<String, Object>? rawOptions})
      : super(
          topology,
          {
            ..._command,
            keyDatabaseName: db?.databaseName ?? 'admin',
            if (filled(username))
              keySaslSupportedMechs: '${db?.databaseName ?? 'admin'}.$username'
          },
          <String, Object>{...?helloOptions?.options, ...?rawOptions},
        );

  Future<HelloResult> executeDocument() async {
    var result = await super.execute();
    return HelloResult(result);
  }
/* 
  @override
  Future<Map<String, Object?>> executeOnServer(Server server) async {
    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    return server.executeMessage(message);
  } */
}
