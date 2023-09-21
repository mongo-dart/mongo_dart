import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:mongo_dart/mongo_dart_old.dart';

import '../settings/connection_string_options.dart';
import '../core/auth/select_authentication_mechanism.dart';
import '../core/error/mongo_dart_error.dart';
import '../core/info/server_config.dart';
import '../settings/default_settings.dart';
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
  ReadPreference? localReadPreference;

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
      case ConnectionStringOptions.tlsCertificateKeyFilePassword:
        options.tlsCertificateKeyFilePassword = value;
        break;
      case ConnectionStringOptions.tlsCAFile:
        options.tlsCAFile = value;
        options.tls = true;
        break;
      case ConnectionStringOptions.tlsAllowInvalidCertificates:
        if (value == 'true') {
          options.tlsAllowInvalidCertificates = true;
          options.tls = true;
        }
        break;
      case ConnectionStringOptions.authSource:
        localAuthDbName = value;
        break;
      case ConnectionStringOptions.authMechanism:
        options.authenticationMechanism = selectAuthenticationMechanism(value);
        break;
      case ConnectionStringOptions.maxPoolSize:
        var intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0) {
          options.connectionPoolSettings.maxPoolSize = intValue;
          if (options.connectionPoolSettings.maxPoolSize != 0 &&
              options.connectionPoolSettings.minPoolSize >
                  options.connectionPoolSettings.maxPoolSize) {
            options.connectionPoolSettings.minPoolSize =
                options.connectionPoolSettings.maxPoolSize;
          }
        }
        break;
      case ConnectionStringOptions.minPoolSize:
        var intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0) {
          options.connectionPoolSettings.maxPoolSize != 0 &&
                  options.connectionPoolSettings.maxPoolSize < intValue
              ? options.connectionPoolSettings.minPoolSize =
                  options.connectionPoolSettings.maxPoolSize
              : options.connectionPoolSettings.minPoolSize = intValue;
        }
        break;
      case ConnectionStringOptions.maxIdleTimeMS:
        var intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0) {
          options.connectionPoolSettings.maxIdleTimeMS = intValue;
        }
        break;
      case ConnectionStringOptions.waitQueueMultiple:
        var intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0) {
          options.connectionPoolSettings.waitQueueMultiple = intValue;
        }
        break;
      case ConnectionStringOptions.waitQueueTimeoutMS:
        var intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0) {
          options.connectionPoolSettings.waitQueueTimeoutMS = intValue;
        }
        break;
      case ConnectionStringOptions.readPreference:
        if (ReadPreferenceMode.values
            .any((element) => element.toString() == value)) {
          var mode = ReadPreferenceMode.values
              .firstWhere((element) => element.toString() == value);
          if (localReadPreference == null) {
            localReadPreference = ReadPreference(mode);
          } else {
            ReadPreference readPref = localReadPreference!;
            if (readPref.mode != mode) {
              localReadPreference = ReadPreference(mode,
                  tags: readPref.tags,
                  maxStalenessSeconds: readPref.maxStalenessSeconds,
                  hedgeOptions: readPref.hedgeOptions);
            }
          }
        } else {
          throw MongoDartError('The ${ConnectionStringOptions.readPreference} '
              'parameter contains the wrong value $value');
        }
        break;
      case ConnectionStringOptions.maxStalenessSeconds:
        var locMaxStalenessSecond = int.tryParse(value);
        if (locMaxStalenessSecond == null || locMaxStalenessSecond < 0) {
          throw ArgumentError('maxStalenessSeconds must be a positive integer');
        }
        localReadPreference = ReadPreference(
            localReadPreference?.mode ?? ReadPreferenceMode.primary,
            tags: localReadPreference?.tags,
            maxStalenessSeconds: locMaxStalenessSecond,
            hedgeOptions: localReadPreference?.hedgeOptions);
        break;
      case ConnectionStringOptions.readPreferenceTags:
        localReadPreference = ReadPreference(
            localReadPreference?.mode ?? ReadPreferenceMode.primary,
            tags: localReadPreference?.tags ?? <TagSet>[],
            maxStalenessSeconds: localReadPreference?.maxStalenessSeconds,
            hedgeOptions: localReadPreference?.hedgeOptions);
        TagSet newTagSet = <String, String>{};
        if (value.isNotEmpty) {
          var pairs = value.split(',');

          for (var element in pairs) {
            if (element.isEmpty) {
              throw ArgumentError('The value "$element" is not a valid '
                  '${ConnectionStringOptions.readPreferenceTags} parameter');
            }
            var keyValue = element.split(':');
            if (keyValue.length != 2) {
              throw ArgumentError('The value "$element" is not a valid '
                  '${ConnectionStringOptions.readPreferenceTags} parameter');
            }
            newTagSet[keyValue.first] = keyValue.last;
          }
          localReadPreference!.tags!.add(newTagSet);
        }

        break;
      default:
        throw MongoDartError('Unknown CL parameter: $queryParam');
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
