part of mongo;

class ServerConfig{
  String host;
  int port;
  String userName;
  String password;
  ServerConfig({this.host: '127.0.0.1', this.port: 27017});
}