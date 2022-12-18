import 'package:meta/meta.dart';
import 'package:mongo_dart/src/topology/server.dart';

import 'abstract/topology.dart';

class ReplicaSet extends Topology {
  ReplicaSet(super.hostsSeedList, super.mongoClientOptions,
      {super.detectedServers})
      : super.protected() {
    updateServersStatus();
  }

  @override
  @protected
  Future<Set<Server>> addOtherServers(
      Server server, Set<Server> additionalServers) async {
    var addedServers = <Server>{};
    if (server.hello?.hosts != null) {
      for (var url in server.hello!.hosts!) {
        if (servers.any((element) => element.url == url)) {
          continue;
        }
        if (additionalServers.any((element) => element.url == url)) {
          continue;
        }
        var serverConfig =
            await parseUri(Uri.parse('mongodb://$url'), mongoClientOptions);
        var server = Server(serverConfig, mongoClientOptions);
        addedServers.add(server);
      }
    }

    return addedServers;
  }
}
