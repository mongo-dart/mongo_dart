import 'package:mongo_dart/src/commands/base/command_operation.dart';

import '../../../database/db.dart';

class PingCommand extends CommandOperation {
  PingCommand(Db db) : super(db, <String, Object>{}, command: {'ping': 1});
}
