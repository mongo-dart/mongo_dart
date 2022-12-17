import 'package:mongo_dart/src/topology/server.dart';

import 'abstract/topology.dart';

class Standalone extends Topology {
  Standalone(super.hostsSeedList, super.mongoClientOptionser,
      {Server? connectedServer})
      : super.protected();
}
