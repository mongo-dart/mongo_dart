import 'package:meta/meta.dart';
import 'package:mongo_dart/src/topology/server.dart';

import '../command/parameters/read_preference.dart';
import '../core/error/mongo_dart_error.dart';
import 'abstract/topology.dart';

class ReplicaSet extends Topology {
  ReplicaSet(super.hostsSeedList, super.mongoClientOptions,
      {super.detectedServers})
      : super.protected() {
    updateServersStatus();
  }

  Set<Server> secondaries = <Server>{};

  @override
  bool get isReadOnly =>
      servers.every((element) => element.isConnected && element.isReadOnlyMode);

  @override
  Server getServer({ReadPreferenceMode? readPreferenceMode}) {
    var locReadPreferenceMode =
        readPreferenceMode ?? ReadPreferenceMode.primary;
    switch (locReadPreferenceMode) {
      case ReadPreferenceMode.primary:
        return primary != null
            ? primary!
            : throw MongoDartError('No primary detected');
      case ReadPreferenceMode.primaryPreferred:
        return primary != null && primary!.isConnected
            ? primary!
            : firstSecondary();
      case ReadPreferenceMode.secondary:
        return firstSecondary();
      case ReadPreferenceMode.secondaryPreferred:
        return firstSecondary(acceptAlsoPrimary: true);
      case ReadPreferenceMode.nearest:
        return nearest();
    }
  }

  @override
  Future<void> updateServersStatus() async {
    await super.updateServersStatus();
    updateServerClassification();
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

  updateServerClassification() {
    primary = null;
    secondaries.clear();
    for (Server server in servers) {
      if (server.isWritablePrimary) {
        primary = server;
      } else {
        secondaries.add(server);
      }
    }
  }

  Server firstSecondary({bool? acceptAlsoPrimary}) {
    acceptAlsoPrimary ??= false;
    for (Server secondary in secondaries) {
      if (secondary.isConnected) {
        return secondary;
      }
    }
    return secondaries.isNotEmpty
        ? secondaries.first
        : (acceptAlsoPrimary && primary != null
            ? primary!
            : throw MongoDartError('No server detected'));
  }
}
