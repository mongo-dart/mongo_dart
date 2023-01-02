import 'abstract/topology.dart';

class SharderdCluster extends Topology {
  SharderdCluster(super.mongoClient, super.hostsSeedList, 
      {super.detectedServers})
      : super.protected() {
    type = TopologyType.shardedCluster;
  }
}
