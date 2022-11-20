import 'abstract/topology.dart';

class Standalone extends Topology {
  Standalone(super.hostsSeedList, super.mongoClientOptions) : super.protected();
}
