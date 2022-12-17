import 'abstract/topology.dart';

class ReplicaSet extends Topology {
  ReplicaSet(super.hostsSeedList, super.mongoClientOptions) : super.protected();


}
