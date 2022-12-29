import 'package:meta/meta.dart';
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../database/document_types.dart';
import '../../database/mongo_database.dart';
import '../../topology/server.dart';
import 'operation_base.dart';

class DbAdminCommandOperation extends OperationBase {
  MongoDatabase db;
  Command command;

  DbAdminCommandOperation(this.db, this.command, {Options? options})
      : super(options);

  Command $buildCommand() => command;

  @override
  Future<MongoDocument> execute() async => executeOnServer(
      db.topology.getServer(readPreferenceMode: db.readPreference?.mode));

  @override
  @protected
  Future<MongoDocument> executeOnServer(Server server) async {
    var command = <String, dynamic>{...$buildCommand(), key$Db: 'admin'};
    options.removeWhere((key, value) => command.containsKey(key));

    command.addAll(options);

    var modernMessage = MongoModernMessage(command);
    return server.executeMessage(modernMessage);
  }
}
