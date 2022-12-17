import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

import '../../../core/error/mongo_dart_error.dart';
import '../../../database/mongo_database.dart';
import '../../../topology/server.dart';
import '../../base/server_command.dart';

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
class HelloCommand extends ServerCommand {
  HelloCommand(this.server,
      {MongoDatabase? db,
      String? username,
      HelloOptions? helloOptions,
      Map<String, Object>? rawOptions})
      : super(
          {
            ..._command,
            keyDatabaseName: db?.databaseName ?? 'admin',
            if (filled(username))
              keySaslSupportedMechs: '${db?.databaseName ?? 'admin'}.$username'
          },
          <String, Object>{...?helloOptions?.options, ...?rawOptions},
        );

  Server server;

  Future<HelloResult> executeDocument() async {
    var result = await execute();
    return HelloResult(result);
  }

  @override
  Future<Map<String, Object?>> execute() async => super.executeOnServer(server);

  @override
  Future<Map<String, Object?>> executeOnServer(Server server) async =>
      throw MongoDartError('Do not use this methos, use execute instead');
}
