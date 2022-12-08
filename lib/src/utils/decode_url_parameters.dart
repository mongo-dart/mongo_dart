import 'dart:typed_data' show Uint8List;

import 'package:universal_io/io.dart' show File;

import '../configuration/connection_string_options.dart';
import '../core/auth/select_authentication_mechanism.dart';
import '../core/error/mongo_dart_error.dart';
import '../core/info/server_config.dart';
import '../configuration/default_settings.dart';
import '../mongo_client_options.dart';

/// Decode the url paramters
///
/// Decodes the parameters and updates te received MongoClientOptionsInstance
Future<ServerConfig> decodeUrlParameters(
    Uri uri, MongoClientOptions options) async {
  if (options.tlsAllowInvalidCertificates ||
      options.tlsCAFile != null ||
      options.tlsCertificateKeyFile != null) {
    options.tls = true;
  }

  if (uri.scheme != 'mongodb') {
    throw MongoDartError(
        'Invalid scheme in uri: ${uri.toString()} ${uri.scheme}');
  }

  String? localAuthDbName;

  uri.queryParameters.forEach((String queryParam, String value) {
    if (value.isEmpty) {
      return;
    }
    switch (queryParam) {
      case ConnectionStringOptions.replicaSet:
        options.replicaSet = value;
        break;
      case ConnectionStringOptions.ssl:
      case ConnectionStringOptions.tls:
        if (value == 'true') {
          options.tls = true;
        }
        break;
      case ConnectionStringOptions.tlsCertificateKeyFile:
        options.tlsCertificateKeyFile = value;
        options.tls = true;
        break;
      default:
        throw MongoDartError('Unknown CL parameter: $queryParam');
    }
    if (queryParam == ConnectionStringOptions.tlsCertificateKeyFilePassword &&
        value.isNotEmpty) {
      options.tlsCertificateKeyFilePassword = value;
    }
    if (queryParam == ConnectionStringOptions.tlsCAFile && value.isNotEmpty) {
      options.tlsCAFile = value;
      options.tls = true;
    }

    if (queryParam == ConnectionStringOptions.tlsAllowInvalidCertificates &&
        value == 'true') {
      options.tlsAllowInvalidCertificates = true;
      options.tls = true;
    }
    if (queryParam == ConnectionStringOptions.authSource) {
      localAuthDbName = value;
    }

    if (queryParam == ConnectionStringOptions.authMechanism) {
      options.authenticationMechanism = selectAuthenticationMechanism(value);
    }

    // ******************** POOL SETTINGS ***
    if (queryParam == ConnectionStringOptions.maxPoolSize && value.isNotEmpty) {
      var intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0) {
        options.maxPoolSize = intValue;
      }
    }
    if (queryParam == ConnectionStringOptions.minPoolSize && value.isNotEmpty) {
      var intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0) {
        options.minPoolSize = intValue;
      }
    }
    if (queryParam == ConnectionStringOptions.maxIdleTimeMS &&
        value.isNotEmpty) {
      var intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0) {
        options.maxIdleTimeMS = intValue;
      }
    }
    if (queryParam == ConnectionStringOptions.waitQueueMultiple &&
        value.isNotEmpty) {
      var intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0) {
        options.waitQueueMultiple = intValue;
      }
    }
    if (queryParam == ConnectionStringOptions.waitQueueTimeoutMS &&
        value.isNotEmpty) {
      var intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0) {
        options.waitQueueTimeoutMS = intValue;
      }
    }
  });

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

  if (uri.userInfo.isNotEmpty) {
    var userInfo = uri.userInfo.split(':');

    if (userInfo.length != 2) {
      throw MongoDartError('Invalid format of userInfo field: ${uri.userInfo}');
    }

    serverConfig.userName = Uri.decodeComponent(userInfo[0]);
    serverConfig.password = Uri.decodeComponent(userInfo[1]);
  }

  if (uri.path.isNotEmpty) {
    options.defaultDbName = uri.path.replaceAll('/', '');
  } else {
    options.defaultDbName = defMongoDbName;
  }

  options.authSource =
      localAuthDbName ?? options.defaultDbName ?? defMongoAuthDbName;

  return serverConfig;
}
