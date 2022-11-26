import 'package:mongo_dart/src/commands/base/server_command.dart';

import '../../core/error/mongo_dart_error.dart';
import '../../topology/abstract/topology.dart';
import '../../topology/server.dart';
import '../parameters/read_preference.dart' show ReadPreference;

/// Run a simple command
///
/// Designed for system commands where Db/Collection are not needed
class SimpleCommand extends ServerCommand {
  SimpleCommand(this.topology, super.command, super.options,
      {super.aspect, ReadPreference? readPreference})
      : readPreference = readPreference ?? ReadPreference.primary,
        super();

  ReadPreference readPreference;
  Topology topology;

  Future<Map<String, Object?>> execute() async {
    var server = topology.getServer(readPreference);
    return super.executeOnServer(server);
  }

  @override
  Future<Map<String, Object?>> executeOnServer(Server server) async =>
      throw MongoDartError('Do not use this methos, use execute instead');
}
