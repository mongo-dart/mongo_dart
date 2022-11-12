import 'package:mongo_dart/mongo_dart_old.dart' show Db;
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../core/network/abstract/connection_base.dart';
import '../../core/topology/server.dart';
import 'operation_base.dart';

class DbAdminCommandOperation extends OperationBase {
  Db db;
  Map<String, Object> command;

  DbAdminCommandOperation(this.db, this.command,
      {Map<String, Object>? options, ConnectionBase? connection})
      : super(options, connection: connection);

  Map<String, Object> $buildCommand() => command;

  @override
  Future<Map<String, Object?>> execute(Server server,
      {ConnectionBase? connection}) async {
    var command = <String, Object>{
      ...$buildCommand(),
      keyDatabaseName: 'admin'
    };
    options.removeWhere((key, value) => command.containsKey(key));

    command.addAll(options);

    var modernMessage = MongoModernMessage(command);
    return server.executeModernMessage(modernMessage, connection: connection);
  }
}
