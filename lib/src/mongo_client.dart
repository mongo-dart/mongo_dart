import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:mongo_dart/src_old/auth/auth.dart';
import 'package:universal_io/io.dart';

import '../src_old/auth/scram_sha1_authenticator.dart';
import '../src_old/auth/scram_sha256_authenticator.dart';
import 'core/error/mongo_dart_error.dart';
import 'core/info/server_config.dart';
import 'core/topology/abstract/topology.dart';
import 'default_settings.dart';
import 'mongo_client_options.dart';
import 'uri_parameters.dart';
import 'write_concern.dart';

typedef ServerApiVersion = Map<String, String>;
const ServerApiVersion serverApiVersion = <String, String>{'v1': '1'};

abstract class ServerApi {
  ServerApi(this.version);

  ServerApiVersion version;
  bool? strict;
  bool? deprecationErrors;
}

abstract class DriverInfo {
  String? name;
  String? version;
  String? platform;
}

abstract class Auth {
  /// The username for auth
  String? username;

  /// The password for auth
  String? password;
}

class MongoClient {
  MongoClient(this.url, {MongoClientOptions? mongoClientOptions}) {
    this.mongoClientOptions = mongoClientOptions ?? MongoClientOptions();
  }

  final Logger log = Logger('Mongo Client');

  String url;
  late MongoClientOptions mongoClientOptions;
  Topology? topology;
  Set activeSessions = {}; // Todo, create the session object
  String defaultDatabaseName = defMongoDbName;
  String defaultAuthDbName = defMongoAuthDbName;
  AuthenticationScheme authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;

  // ReadConcern
  // Read Preference
  WriteConcern? writeConcern;

  Future connect() async {}
  Future close() async {}

  /// If no name passed, the url specified db is used
  Future db(String? dbName) async {}

  Future<ServerConfig> decodeUrlParameters() async {
    mongoClientOptions.tls ??= false;
    mongoClientOptions.tlsAllowInvalidCertificates ??= false;
    if (mongoClientOptions.tlsAllowInvalidCertificates! ||
        mongoClientOptions.tlsCAFile != null ||
        mongoClientOptions.tlsCertificateKeyFile != null) {
      mongoClientOptions.tls = true;
    }
    var uri = Uri.parse(url);

    if (uri.scheme != 'mongodb') {
      throw MongoDartError('Invalid scheme in uri: $url ${uri.scheme}');
    }

    String? localAuthDbName;

    uri.queryParameters.forEach((String queryParam, String value) {
      if (queryParam == UriParameters.authMechanism) {
        authenticationScheme = selectAuthenticationMechanism(value);
      }

      if (queryParam == UriParameters.authSource) {
        localAuthDbName = value;
      }

      if ((queryParam == UriParameters.tls ||
              queryParam == UriParameters.ssl) &&
          value == 'true') {
        mongoClientOptions.tls = true;
      }
      if (queryParam == UriParameters.tlsAllowInvalidCertificates &&
          value == 'true') {
        mongoClientOptions.tlsAllowInvalidCertificates = true;
        mongoClientOptions.tls = true;
      }
      if (queryParam == UriParameters.tlsCAFile && value.isNotEmpty) {
        mongoClientOptions.tlsCAFile = value;
        mongoClientOptions.tls = true;
      }
      if (queryParam == UriParameters.tlsCertificateKeyFile &&
          value.isNotEmpty) {
        mongoClientOptions.tlsCertificateKeyFile = value;
        mongoClientOptions.tls = true;
      }
      if (queryParam == UriParameters.tlsCertificateKeyFilePassword &&
          value.isNotEmpty) {
        mongoClientOptions.tlsCertificateKeyFilePassword = value;
      }
    });

    Uint8List? tlsCAFileContent;
    if (mongoClientOptions.tlsCAFile != null) {
      tlsCAFileContent =
          await File(mongoClientOptions.tlsCAFile!).readAsBytes();
    }
    Uint8List? tlsCertificateKeyFileContent;
    if (mongoClientOptions.tlsCertificateKeyFile != null) {
      tlsCertificateKeyFileContent =
          await File(mongoClientOptions.tlsCertificateKeyFile!).readAsBytes();
    }
    if (mongoClientOptions.tlsCertificateKeyFilePassword != null &&
        mongoClientOptions.tlsCertificateKeyFile == null) {
      throw MongoDartError('Missing tlsCertificateKeyFile parameter');
    }

    var serverConfig = ServerConfig(
        host: uri.host,
        port: uri.port,
        isSecure: mongoClientOptions.tls,
        tlsAllowInvalidCertificates:
            mongoClientOptions.tlsAllowInvalidCertificates,
        tlsCAFileContent: tlsCAFileContent,
        tlsCertificateKeyFileContent: tlsCertificateKeyFileContent,
        tlsCertificateKeyFilePassword:
            mongoClientOptions.tlsCertificateKeyFilePassword);

    if (serverConfig.port == 0) {
      serverConfig.port = defMongoPort;
    }

    if (uri.userInfo.isNotEmpty) {
      var userInfo = uri.userInfo.split(':');

      if (userInfo.length != 2) {
        throw MongoDartError('Invalid format of userInfo field: $uri.userInfo');
      }

      serverConfig.userName = Uri.decodeComponent(userInfo[0]);
      serverConfig.password = Uri.decodeComponent(userInfo[1]);
    }

    if (uri.path.isNotEmpty) {
      defaultDatabaseName = uri.path.replaceAll('/', '');
      localAuthDbName ??= defaultDatabaseName;
    }

    defaultAuthDbName = localAuthDbName ?? defMongoAuthDbName;

    return serverConfig;
  }

  AuthenticationScheme selectAuthenticationMechanism(
      String authenticationSchemeName) {
    if (authenticationSchemeName == ScramSha1Authenticator.name) {
      return AuthenticationScheme.SCRAM_SHA_1;
    } else if (authenticationSchemeName == ScramSha256Authenticator.name) {
      return AuthenticationScheme.SCRAM_SHA_256;
    } else {
      throw MongoDartError('Provided authentication scheme is '
          'not supported : $authenticationSchemeName');
    }
  }
}
