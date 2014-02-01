part of mongo_dart;

class _ConnectionManager {
  final _log = new Logger('ConnectionManager');
  final db;
  final _connectionPool = new Map<String,_Connection>();
  final replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  final sendQueue       = new Queue<MongoMessage>();
  _Connection _masterConnection;

  _ConnectionManager(this.db);
  get masterConnection => _masterConnection;

  Future _connect(_Connection connection) {
    return connection.connect().then((v) {
      if (connection.serverConfig.userName == null) {
        _log.fine('$db: ${connection.serverConfig.hostUrl} connected');
        return v;
      } else {
        return db.authenticate(connection.serverConfig.userName, connection.serverConfig.password, connection: connection).then((v) {
          _log.fine('$db: ${connection.serverConfig.hostUrl} connected');
          return v;
        });
      }
    }).then((v) {
      DbCommand isMasterCommand = DbCommand.createIsMasterCommand(db);
      return connection.query(isMasterCommand);
    }).then((replyMessage) {
      _log.fine(replyMessage.documents[0].toString());
      var master = replyMessage.documents[0]["ismaster"];
      connection.isMaster = master;
      if (master) {
        _masterConnection = connection;
      }
    });
  }

  Future open(WriteConcern writeConcern){
    return Future.forEach(_connectionPool.keys, (hostUrl) {
      var connection = _connectionPool[hostUrl];
      return _connect(connection);
    });
  }

  Future close(){
    while (!sendQueue.isEmpty){
      masterConnection._sendBuffer();
    }
    sendQueue.clear();

    return Future.forEach(_connectionPool.keys, (hostUrl) {
      var connection = _connectionPool[hostUrl];
      _log.fine('$db: ${connection.serverConfig.hostUrl} closed');
      return connection.close();
    }).then((_) {
      replyCompleters.clear();
    });
  }

  addConnection(ServerConfig serverConfig) {
    var connection = new _Connection(this, serverConfig);
    _connectionPool[serverConfig.hostUrl] = connection;
  }

  bool removeConnection(_Connection connection) {
    return _connectionPool.remove(connection.serverConfig.hostUrl);
  }
}
