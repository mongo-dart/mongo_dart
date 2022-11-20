import 'package:mongo_dart/src/commands/base/command_operation.dart';

import '../../../database/mongo_database.dart';

class PingCommand extends CommandOperation {
  PingCommand(MongoDatabase db)
      : super(db, <String, Object>{}, command: {'ping': 1});
}
