part of mongo_dart;

class _ConnectionManager {
  final _connectionPool = new List<_Connection>();
  final replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  final sendQueue       = new Queue<MongoMessage>();
  
  // TODO Select the master instance
  get masterConnection => _connectionPool[0];
  
  addConnection(ServerConfig serverConfig) {
    var connection = new _Connection(this, serverConfig);
    _connectionPool.add(connection);
  }
  
  bool removeConnection(_Connection connection) {
    return _connectionPool.remove(connection); 
  }
}
