import 'dart:io' show Platform;

/// Represents the client metadata that can be provided to the initial
/// handshake (hello).
class ClientMetadata {
  final DriverMetadata driver = DriverMetadata();
  final OsMetadata os = OsMetadata();
  final String platform = 'dart $Platform.version';
  final ApplicationMetadata? application;

  ClientMetadata(this.application);
}

/// Information about the driver itself.
class DriverMetadata {
  final String name = 'mongodb_dart';
  // TODO: Get version without extra I/O
  final String version = 'temp';
}

/// Information about the operating system.
class OsMetadata {
  final String type = Platform.operatingSystem;
  final String? name;
  final String? architecture;
  final String version = Platform.version;

  OsMetadata({this.name, this.architecture});
}

/// Application information, only a descriptive name.
class ApplicationMetadata {
  final String name;

  // TODO: Trim name to 128 bytes.
  ApplicationMetadata(this.name);
}
