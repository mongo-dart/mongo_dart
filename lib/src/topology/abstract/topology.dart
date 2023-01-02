import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:universal_io/io.dart';

import '../../core/error/mongo_dart_error.dart';
import '../../core/info/server_config.dart';
import '../../mongo_client.dart';
import '../../settings/default_settings.dart';
import '../../mongo_client_options.dart';
import '../server.dart';

enum TopologyType { standalone, replicaSet, shardedCluster, unknown }

abstract class Topology {
  @protected
  Topology.protected(this.mongoClient, this.hostsSeedList,
      {List<Server>? detectedServers}) {
    if (detectedServers != null) {
      servers.addAll(detectedServers);
    }
  }

  final log = Logger('Topology');
  TopologyType? type;
  final List<Uri> hostsSeedList;
  final MongoClient mongoClient;
  MongoClientOptions get mongoClientOptions => mongoClient.mongoClientOptions;

  /// Returns the primary writable server
  Server? primary;

  List<Server> servers = <Server>[];

  List<Uri> get seedList => hostsSeedList.toList();
  bool get isConnected => servers.any((element) => element.isConnected);

  // *** To be overridden. This behavior works just for standalone topology
  /// The return value depends on the topology
  /// In case the topology is not connected, the return values is meaningless.
  /// - standalone -> returns readOnly state of the server
  /// - replicaSet -> true if the topology is connected but no primary it is, otherwise false
  /// - sharderCluster -> true if all the mongos are in readOnlyMode.
  bool get isReadOnly => isConnected ? servers.first.isReadOnlyMode : true;

  // *** To be overridden. This behavior works just for standalone typology
  /// Retruns the server based on the readPreference
  Server getServer(
          {ReadPreferenceMode? readPreferenceMode =
              ReadPreferenceMode.primary}) =>
      isConnected ? servers.first : throw MongoDartError('No primary detected');

  Future connect() async {
    if (servers.isEmpty) {
      await addServersFromSeedList();
      await updateServersStatus();
    }
  }

  Future<void> addServersFromSeedList() async {
    for (var element in hostsSeedList) {
      var serverConfig = await parseUri(element, mongoClientOptions);
      var server = Server(mongoClient, serverConfig, mongoClientOptions);
      servers.add(server);
      await server.connect();
    }
  }

  @protected
  Future<void> updateServersStatus() async {
    var additionalServers = <Server>{};
    for (var server in servers) {
      if (!server.isConnected) {
        await server.connect();
      }
      await server.refreshStatus();
      additionalServers
          .addAll(await addOtherServers(server, additionalServers));
    }

    for (var server in additionalServers) {
      if (!server.isConnected) {
        await server.connect();
      }
      await server.refreshStatus();
      servers.add(server);
    }
  }

  // *** To be overridden. This behavior works just for standalone typology
  @protected
  Future<Set<Server>> addOtherServers(
          Server server, Set<Server> additionalServers) async =>
      <Server>{};

  Future<ServerConfig> parseUri(Uri uri, MongoClientOptions options) async {
    if (uri.scheme != 'mongodb') {
      throw MongoDartError('Invalid scheme in uri: ${uri.scheme}');
    }

    Uint8List? tlsCAFileContent;
    if (options.tlsCAFile != null) {
      tlsCAFileContent = await File(options.tlsCAFile!).readAsBytes();
    }
    Uint8List? tlsCertificateKeyFileContent;
    if (options.tlsCertificateKeyFile != null) {
      tlsCertificateKeyFileContent =
          await File(options.tlsCertificateKeyFile!).readAsBytes();
    }
    if (options.tlsCertificateKeyFilePassword != null &&
        options.tlsCertificateKeyFile == null) {
      throw MongoDartError('Missing tlsCertificateKeyFile parameter');
    }

    var serverConfig = ServerConfig(
        host: uri.host,
        port: uri.port,
        isSecure: options.tls,
        tlsAllowInvalidCertificates: options.tlsAllowInvalidCertificates,
        tlsCAFileContent: tlsCAFileContent,
        tlsCertificateKeyFileContent: tlsCertificateKeyFileContent,
        tlsCertificateKeyFilePassword: options.tlsCertificateKeyFilePassword);

    if (serverConfig.port == 0) {
      serverConfig.port = defMongoPort;
    }

    serverConfig.userName = options.auth?.username;
    serverConfig.password = options.auth?.password;

    return serverConfig;
  }

  Server nearest() {
    int? lowestMS;
    Server? selectedServer;
    for (Server server in servers) {
      if (server.isConnected) {
        if (lowestMS == null || server.lastHelloExecutionMS < lowestMS) {
          lowestMS = server.hello!.localTime.millisecondsSinceEpoch;
          selectedServer = server;
        }
      }
    }
    return selectedServer ?? (throw MongoDartError('No server detected'));
  }
}
