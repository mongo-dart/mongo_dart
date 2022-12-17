import 'abstract/topology.dart';

class SharderdCluster extends Topology {
  SharderdCluster(super.hostsSeedList, super.mongoClientOptions)
      : super.protected();
}
