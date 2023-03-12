import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/server_command.dart';

import '../../topology/abstract/topology.dart';
import '../../topology/server.dart';

/// Run a simple command
///
/// Designed for system commands where Db/Collection are not needed
base class SimpleCommand extends ServerCommand {
  SimpleCommand(super.mongoClient, super.command,
      {super.options,
      super.session,
      super.aspect,
      ReadPreference? readPreference})
      : super();

  /// The ReadPreference Object has prefernce with respect to the options
  /// ReadPrefernce Specs
  ReadPreference? readPreference;
  //Topology topology;

  @override
  @nonVirtual
  Future<MongoDocument> process() async {
    Server? server;
    if (topology.type == TopologyType.standalone) {
      ReadPreference.removeReadPreferenceFromOptions(options);
      server = topology.primary;
    } else if (topology.type == TopologyType.replicaSet) {
      server = topology.getServer(
          readPreferenceMode:
              readPreference?.mode ?? ReadPreferenceMode.primary);
    } else if (topology.type == TopologyType.shardedCluster) {
      server = topology.getServer();
      readPreference ??= options[keyReadPreference] == null
          ? null
          : ReadPreference.fromOptions(options, removeFromOriginalMap: true);
      ReadPreference.removeReadPreferenceFromOptions(options);
      if (readPreference != null) {
        options = {...options, ...readPreference!.toMap()};
      }
    }

    return super.executeOnServer(
        server ?? (throw MongoDartError('No server detected')));
  }

  /* @override
  @Deprecated('Use execute instead')
  Future<Map<String, dynamic>> executeOnServer(Server server,
          {ClientSession? session}) async =>
      throw MongoDartError('Do not use this method, use execute instead'); */
}