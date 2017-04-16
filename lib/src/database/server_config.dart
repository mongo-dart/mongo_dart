part of mongo_dart;

class ServerConfig {
  String host;
  int port;
  String userName;
  String password;
  ServerConfig([this.host = '127.0.0.1', this.port = 27017]);
  String get hostUrl => "$host:${port.toString()}";
}
