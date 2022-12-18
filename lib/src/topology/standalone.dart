import 'abstract/topology.dart';

class Standalone extends Topology {
  Standalone(super.hostsSeedList, super.mongoClientOptionser,
      {super.detectedServers})
      : super.protected();
}
