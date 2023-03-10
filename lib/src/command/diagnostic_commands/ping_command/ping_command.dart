import 'package:mongo_dart/src/command/base/simple_command.dart';

import '../../../mongo_client.dart';

base class PingCommand extends SimpleCommand {
  PingCommand(MongoClient mongoClient, {super.session})
      : super(mongoClient, {'ping': 1});
}
