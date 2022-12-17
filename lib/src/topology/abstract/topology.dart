import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:universal_io/io.dart';

import '../../core/error/mongo_dart_error.dart';
import '../../core/info/server_config.dart';
import '../../settings/default_settings.dart';
import '../../mongo_client_options.dart';
import '../server.dart';

enum TopologyType { standalone, replicaSet, shardedCluster, unknown }

abstract class Topology {
  @protected
  Topology.protected(this.hostsSeedList, this.mongoClientOptions,
      {Server? connectedServer}) {
    if (connectedServer != null) {
      servers.add(connectedServer);
    }
  }

  final log = Logger('Topology');
  TopologyType? type;
  final List<Uri> hostsSeedList;
  MongoClientOptions mongoClientOptions;

  List<Server> servers = <Server>[];

  List<Uri> get seedList => hostsSeedList.toList();
  bool get isConnected => servers.any((element) => element.isConnected);

  // *** To be overridden. This behavior works just for standalone typology
  /// The return value depends on the tipology
  /// In case the tipology is not connected, the return values is meaningless.
  /// - standalone -> returns always false
  /// - replicaSet -> true if the tipology is connected but no primary it is, otherwise false
  /// - sharderCluster -> true if all the mongos are in readOnlyMode.
  bool get isReadOnly => false;

  // *** To be overridden. This behavior works for standalone and replica set typology
  /// Returns the primary writable server
  Server get primary =>
      servers.firstWhere((element) => element.isWritablePrimary);

  // *** To be overridden. This behavior works just for standalone typology
  /// Retruns the server based on the readPreference
  Server getServer(ReadPreference readPreference) => servers.first;

  Future connect() async {
    if (servers.isEmpty) {
      await initialConnection();
    }
  }

  Future<void> initialConnection() async {
    for (var element in hostsSeedList) {
      var serverConfig = await _parseUri(element, mongoClientOptions);
      var server = Server(serverConfig, mongoClientOptions);
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
      additionalServers.addAll(await addOtherServers());
    }
  }

  // *** To be overridden. This behavior works just for standalone typology
  @protected
  Future<Set<Server>> addOtherServers() async => <Server>{};

  Future<ServerConfig> _parseUri(Uri uri, MongoClientOptions options) async {
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
}
