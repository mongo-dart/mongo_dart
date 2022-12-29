import 'package:mongo_dart/src/command/base/simple_command.dart';

import '../../../topology/abstract/topology.dart';

class PingCommand extends SimpleCommand {
  PingCommand(
    Topology topology,
  ) : super(topology, {'ping': 1}, <String, dynamic>{});
}
