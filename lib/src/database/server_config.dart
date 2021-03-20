part of mongo_dart;

class ServerConfig {
  String host;
  int port;
  bool isSecure;
  bool tlsAllowInvalidCertificates;
  Uint8List tlsCAFileContent;
  
  String userName;
  String password;

  bool isAuthenticated = false;

  ServerConfig(
      {this.host = '127.0.0.1',
      this.port = Db.mongoDefaultPort,
      this.isSecure = false,
      this.tlsAllowInvalidCertificates,
      this.tlsCAFileContent});
  String get hostUrl => '$host:${port.toString()}';
}
