import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:universal_io/io.dart';

import '../../core/error/mongo_dart_error.dart';
import '../../core/info/server_config.dart';
import '../../configuration/default_settings.dart';
import '../../mongo_client_options.dart';
import '../server.dart';
import '../standalone.dart';

enum TopologyType { standalone, replicaSet, shardedCluster, unknown }

abstract class Topology {
  @protected
  Topology.protected(this.hostsSeedList, this.mongoClientOptions);

  factory Topology(List<Uri> hostSeedList, MongoClientOptions options) {
    Topology topology = Standalone(hostSeedList, options);
    topology.type = TopologyType.standalone;
    return topology;
  }

  final log = Logger('Topology');
  TopologyType? type;
  final List<Uri> hostsSeedList;
  MongoClientOptions mongoClientOptions;

  List<Uri> get seedList => hostsSeedList.toList();

  List<Server> servers = <Server>[];

  Server getServer(ReadPreference readPreference) {
    // Todo manage server forwarding
    return servers.first;
  }

  Future connect() async {
    if (servers.isEmpty) {
      return initialConnection();
    }
  }

  Future initialConnection() async {
    for (var element in hostsSeedList) {
      var serverConfig = await _parseUri(element, mongoClientOptions);
      var server = Server(serverConfig);
      servers.add(server);
      await server.connect();
    }
  }

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
