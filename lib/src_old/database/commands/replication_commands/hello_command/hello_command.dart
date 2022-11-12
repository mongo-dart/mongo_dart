import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

import '../../../../../src/core/network/abstract/connection_base.dart';
import '../../../../../src/core/topology/server.dart';

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
      ConnectionBase? connection})
      : super(db, <String, Object>{...?helloOptions?.options, ...?rawOptions},
            command: {
              ..._command,
              if (filled(username))
                keySaslSupportedMechs: '${db.databaseName}.$username'
            },
            connection: connection);

  Future<HelloResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var result = await super.execute(server, connection: connection);
    return HelloResult(result);
  }

  @override
  Future<Map<String, Object?>> execute(Server server,
      {ConnectionBase? connection}) async {
    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    return server.executeModernMessage(message);
  }
}
