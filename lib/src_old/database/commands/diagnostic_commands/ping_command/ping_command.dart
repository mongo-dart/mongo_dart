import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';

class PingCommand extends CommandOperation {
  PingCommand(Db db) : super(db, <String, Object>{}, command: {'ping': 1});
}
