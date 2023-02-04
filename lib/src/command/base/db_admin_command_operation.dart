import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../session/client_session.dart';
import '../../topology/server.dart';
import 'operation_base.dart';

class DbAdminCommandOperation extends OperationBase {
  DbAdminCommandOperation(this.client, this.command,
      {super.session, super.options})
      : super(client);

  MongoClient client;
  Command command;

  Command $buildCommand() => command;

  @override
  Future<MongoDocument> process() async => executeOnServer(
      client.topology
              ?.getServer(readPreferenceMode: client.readPreference?.mode) ??
          (throw MongoDartError('Server not found')),
      session: session);

  @override
  @nonVirtual
  @protected
  Future<MongoDocument> executeOnServer(Server server,
      {ClientSession? session}) async {
    var command = <String, dynamic>{...$buildCommand(), key$Db: 'admin'};
    options.removeWhere((key, value) => command.containsKey(key));

    if (client.serverApi != null) {
      command.addAll(client.serverApi!.options);
    }

    command.addAll(options);

    //var modernMessage = MongoModernMessage(command);
    //return server.executeMessage(modernMessage);
    return server.executeCommand(command, this);
  }
}
