import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart_old.dart';

import '../../utils/split_hosts.dart';
import '../server.dart';
import '../standalone.dart';

enum TopologyType { standalone, replicaSet, shardedCluster }

abstract class Topology {
  @protected
  Topology.protected(String uriString) {
    if (uriString.contains(',')) {
      _hostsSeedList.addAll(splitHosts(uriString));
    } else {
      _hostsSeedList.add(uriString);
    }
  }

  factory Topology(String uriString) {
    Topology topology = Standalone(uriString);
    topology.type = TopologyType.standalone;
    return topology;
  }

  final log = Logger('Topology');
  TopologyType? type;
  final List<String> _hostsSeedList = <String>[];
  List<String> get seedList => _hostsSeedList.toList();

  List<Server> servers = <Server>[];

  Server getServer(ReadPreference readPreference) {
    // Todo manage server forwarding
    return Server();
  }
}
