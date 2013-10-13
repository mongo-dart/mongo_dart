part of mongo_dart;
class _Connection{
  final _log= new Logger('Connection');
  static const int HEADER_SIZE = 16;
  final _replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  ServerConfig serverConfig;
  BsonBinary _bufferToSend;
  Socket socket;
  final _sendQueue = new Queue<MongoMessage>();
  StreamSubscription<List<int>> _socketSubscription;
  bool connected = false;
  bool _closing = false;
  _Connection([this.serverConfig]) {
    if (serverConfig == null){
      serverConfig = new ServerConfig();
    }
  }
  Future<bool> connect(){
    Completer completer = new Completer();
    Socket.connect(serverConfig.host, serverConfig.port).then((Socket _socket) {
/* Socket connected. */
      socket = _socket;
      _socketSubscription = socket
        .transform(new MongoMessageHandler().transformer)
        .listen(_receiveReply,onError: (e) {
        print("Socket error ${e}");
        completer.completeError(e);
      });
      connected = true;
      completer.complete(true);
    }).catchError( (err) {
      completer.completeError(err);
    });
    return completer.future;
  }
  
  void close(){
    _closing = true;
    while (!_sendQueue.isEmpty){
      _sendBuffer();
    }
    _sendQueue.clear();
    socket.close();
    _replyCompleters.clear();
  }
  _sendBuffer(){
    _log.fine('_sendBuffer ${!_sendQueue.isEmpty}');
    if (!_sendQueue.isEmpty) {
      var mongoMessage = _sendQueue.removeFirst();
      socket.add(mongoMessage.serialize().byteList);
    }  
  }
  Future<MongoReplyMessage> query(MongoMessage queryMessage){
    Completer completer = new Completer();
    _replyCompleters[queryMessage.requestId] = completer;    
    _log.fine('Query $queryMessage');
    _sendQueue.addLast(queryMessage);
    _sendBuffer();
    return completer.future;
  }
  void execute(MongoMessage mongoMessage){
    _log.fine('Execute $mongoMessage');
    _sendQueue.addLast(mongoMessage);
    _sendBuffer();
  }
  
  void _receiveReply(MongoReplyMessage reply) {
    _log.fine(reply.toString());
    Completer completer = _replyCompleters.remove(reply.responseTo);
    if (completer != null){
      _log.fine('Completing $reply');
      completer.complete(reply);
    }
    else {
      if (!_closing) {
        _log.info("Unexpected respondTo: ${reply.responseTo} $reply");
      }
    }
  }
}
