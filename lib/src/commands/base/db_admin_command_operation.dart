import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../core/network/abstract/connection_base.dart';
import '../../database/mongo_database.dart';
import '../../topology/server.dart';
import 'operation_base.dart';

class DbAdminCommandOperation extends OperationBase {
  MongoDatabase db;
  Map<String, Object> command;

  DbAdminCommandOperation(this.db, this.command,
      {Map<String, Object>? options, ConnectionBase? connection})
      : super(options);

  Map<String, Object> $buildCommand() => command;

  @override
  Future<Map<String, Object?>> execute() async {
    var server = db.topology.getServer(db.readPreference);
    return super.executeOnServer(server);
  }

  @override
  Future<Map<String, Object?>> executeOnServer(Server server) async {
    var command = <String, Object>{
      ...$buildCommand(),
      keyDatabaseName: 'admin'
    };
    options.removeWhere((key, value) => command.containsKey(key));

    command.addAll(options);

    var modernMessage = MongoModernMessage(command);
    return server.executeMessage(modernMessage);
  }
}
