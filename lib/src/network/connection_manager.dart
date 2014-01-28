part of mongo_dart;

class _ConnectionManager {
  final replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  final sendQueue       = new Queue<MongoMessage>();

  _Connection connection(ServerConfig serverConfig) {
    return new _Connection(this, serverConfig);
  }
}
