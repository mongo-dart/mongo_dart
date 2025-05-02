part of '../../mongo_dart.dart';

class ServerConfig {
  String host;
  int port;
  bool isSecure;
  bool tlsAllowInvalidCertificates;
  Uint8List? tlsCAFileContent;
  Uint8List? tlsCertificateKeyFileContent;
  String? tlsCertificateKeyFilePassword;

  String? userName;
  String? password;

  bool isAuthenticated = false;
  ClientMetadata? clientMetadata;

  ServerConfig(
      {this.host = '127.0.0.1',
      this.port = Db.mongoDefaultPort,
      bool? isSecure,
      bool? tlsAllowInvalidCertificates,
      this.tlsCAFileContent,
      this.tlsCertificateKeyFileContent,
      this.tlsCertificateKeyFilePassword,
      this.clientMetadata})
      : isSecure = isSecure ?? false,
        tlsAllowInvalidCertificates = tlsAllowInvalidCertificates ?? false;
  String get hostUrl => '$host:${port.toString()}';
}
