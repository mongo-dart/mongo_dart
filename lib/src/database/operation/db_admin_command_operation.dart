import 'package:mongo_dart/mongo_dart.dart' show Db;
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'operation_base.dart';

class DbAdminCommandOperation extends OperationBase {
  Db db;
  Map<String, Object> command;
  String namespace;

  DbAdminCommandOperation(this.db, this.command, {Map<String, Object> options})
      : super(options ?? <String, Object>{});

  Map<String, Object> $buildCommand() => command;

  @override
  Future<Map<String, Object>> execute() async {
    final db = this.db;
    //final options = Map.from(this.options);
    var command = $buildCommand();

    command[keyDatabaseName] = 'admin';

    var modernMessage = MongoModernMessage(command);
    return db.executeModernMessage(modernMessage);
  }
}
