import 'dart:io' show Platform;
import 'package:mongo_dart/src/version.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Represents the client metadata that can be provided to the initial
/// handshake (hello).
class ClientMetadata {
  final DriverMetadata driver = DriverMetadata();
  final OsMetadata os = OsMetadata();
  final String platform = 'dart ${Platform.version}';
  final ApplicationMetadata application;

  ClientMetadata(this.application);

  Map<String, Object> get options => <String, Object>{
        keyClient: {
          keyDriver: driver.asMap(),
          keyOs: os.asMap(),
          keyPlatform: platform,
          keyApplication: application.asMap(),
        }
      };
}

/// Information about the driver itself.
class DriverMetadata {
  final String name = mongoDartName;
  final String version = mongoDartVersion;

  Map<String, Object> asMap() {
    return <String, Object>{keyName: name, keyVersion: version};
  }
}

/// Information about the operating system.
class OsMetadata {
  final String type = Platform.operatingSystem;
  // We cannot get these 3 without some I/O, so they are always left out.
  final String? name;
  final String? architecture;
  final String? version;

  OsMetadata({this.name, this.architecture, this.version});

  Map<String, Object> asMap() {
    return <String, Object>{keyType: type};
  }
}

/// Application information, only a descriptive name.
class ApplicationMetadata {
  final String name;

  ApplicationMetadata(String name)
      : name = name.length > 128 ? name.substring(0, 128) : name;

  Map<String, Object> asMap() {
    return <String, Object>{keyName: name};
  }
}
