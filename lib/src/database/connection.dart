part of mongo_dart;
class Connection{
  final _replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  BsonBinary _lengthBuffer;
  ServerConfig serverConfig;
  BsonBinary _bufferToSend;
  final _sendQueue = new Queue<MongoMessage>();
  BsonBinary _messageBuffer;
  Socket socket;
  List _incompleteLengthBytes = [];
  StreamSubscription<List<int>> _socketSubscription;
  bool connected = false;
  bool _closing = false;
  Connection([this.serverConfig]){
    if (serverConfig == null){
      serverConfig = new ServerConfig();
    }
  }
  Future<bool> connect(){
    _lengthBuffer = new BsonBinary(4);
    Completer completer = new Completer();   
    Socket.connect(serverConfig.host, serverConfig.port).then((Socket _socket) {
      /* Socket connected. */
      socket = _socket;
      _socketSubscription = socket.listen(_receiveData,onError: (e) {
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
  _getNextBufferToSend(){
    if (_bufferToSend == null || _bufferToSend.atEnd()){
      if(!_sendQueue.isEmpty){
        MongoMessage message = _sendQueue.removeFirst();
        _log.finer(message.toString());
        _bufferToSend = message.serialize();
        _log.finer(_bufferToSend.hexString);
      } else {
        _bufferToSend = null;
      }
    }
  }
  _sendBuffer(){
    while(_sendQueue.length > 0) {
      _bufferToSend = _sendQueue.removeFirst().serialize();
      socket.add(_bufferToSend.byteList);
    }
  }
  void _receiveData(List<int> data, [int offset = 0, int recursion = 0]) {
    if (_messageBuffer == null){
      if (data.length - offset < 4) {
        _incompleteLengthBytes = data.sublist(offset);
        return;
      }
      _lengthBuffer.byteList.setRange(0, _incompleteLengthBytes.length, _incompleteLengthBytes, offset);     
      _lengthBuffer.byteList.setRange(0 + _incompleteLengthBytes.length, 0 + _incompleteLengthBytes.length + 4 - _incompleteLengthBytes.length, data, offset);
      int messageLength = _lengthBuffer.readInt32();
      if (messageLength == 0) {
        throw 'messageLength == 0 $data';
      }
      _messageBuffer = new BsonBinary(messageLength);
      _messageBuffer.byteList.setRange(0, 4 , _lengthBuffer.byteList);   
      _messageBuffer.offset += 4;
      offset += 4 - _incompleteLengthBytes.length;
      _incompleteLengthBytes = [];
    }
    int delta = min(data.length - offset,_messageBuffer.byteList.length-_messageBuffer.offset);
    if (recursion > 2000) {
      throw 'Maybe we in infinite recursion?';
    }
    _messageBuffer.byteList.setRange(_messageBuffer.offset, _messageBuffer.offset+delta , data, offset);
    _messageBuffer.offset += delta;
    if (_messageBuffer.atEnd()){
      MongoReplyMessage reply = new MongoReplyMessage();
      _messageBuffer.rewind();
      reply.deserialize(_messageBuffer);
      _log.finer(reply.toString());
      _messageBuffer = null;
      _lengthBuffer.rewind();
      Completer completer = _replyCompleters.remove(reply.responseTo);
      if (completer != null){
        _log.finest('Completing $reply');
        completer.complete(reply);
      }
      else {
        if (!_closing) {
          _log.info("Unexpected respondTo: ${reply.responseTo} $reply");
        }
      }
      if (delta + offset < data.length) {
        _receiveData(data, delta + offset, recursion + 1); 
      }  
    }
  }
  Future<MongoReplyMessage> query(MongoMessage queryMessage){
    Completer completer = new Completer();
    _replyCompleters[queryMessage.requestId] = completer;    
    _sendQueue.addLast(queryMessage);
    _log.finest('Query $queryMessage');
    _sendBuffer();
    return completer.future;
  }
  void execute(MongoMessage mongoMessage){
    _log.finest('Execute $mongoMessage');
    _sendQueue.addLast(mongoMessage);
    _sendBuffer();
  }
}
