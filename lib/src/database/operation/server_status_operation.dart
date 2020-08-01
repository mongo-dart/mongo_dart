import 'package:mongo_dart/mongo_dart.dart' show Db;
import 'package:mongo_dart/src/database/operation/db_admin_command_operation.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class ServerStatusOperation extends DbAdminCommandOperation {
  ServerStatusOperation(Db db, {Map<String, Object> options})
      : super(db, <String, Object>{keyServerStatus: 1}, options: options);
}
