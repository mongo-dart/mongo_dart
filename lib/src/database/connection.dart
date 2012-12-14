part of mongo_dart;
class Connection{
  Map<int,Completer<MongoReplyMessage>> _replyCompleters;
  BsonBinary _lengthBuffer;
  ServerConfig serverConfig;
  BsonBinary _bufferToSend;
  Queue<MongoMessage> _sendQueue;
  BsonBinary _messageBuffer;
  Socket socket;
  bool connected = false;
  Connection([this.serverConfig]){
    if (serverConfig == null){
      serverConfig = new ServerConfig();
    }
  }
  Future<bool> connect(){
    _replyCompleters = new Map();
    _sendQueue = new Queue();
    socket = new Socket(serverConfig.host, serverConfig.port);
    Completer completer = new Completer();
    if (socket is! Socket) {
      completer.completeException(new Exception( "can't get send socket"));
    } else {
      _lengthBuffer = new BsonBinary(4);
      socket.onError = (e) {
        print("connect exception ${e}");
        completer.completeException(e);
      };
      socket.onConnect = () {
        connected = true;
        completer.complete(true);
      };
      return completer.future;
    }
  }
  void close(){
    while (!_sendQueue.isEmpty){
      _sendBuffer();
    }
    socket.onData = null;
    socket.onError = null;
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
      socket.outputStream.writeFrom(_bufferToSend.byteList);
    }
  }
  void _receiveData() {
    if (_messageBuffer == null){
      int numBytes = socket.readList(_lengthBuffer.byteList, 0, 4);
      if (numBytes == 0) {
        return;
      }
      int messageLength = _lengthBuffer.readInt32();
      _messageBuffer = new BsonBinary(messageLength);
      _messageBuffer.writeInt(messageLength);
    }
    _messageBuffer.offset += socket.readList(_messageBuffer.byteList,_messageBuffer.offset,_messageBuffer.byteList.length-_messageBuffer.offset);
    if (_messageBuffer.atEnd()){
      MongoReplyMessage reply = new MongoReplyMessage();
      _messageBuffer.rewind();
      reply.deserialize(_messageBuffer);
      _log.finer(reply.toString());
      _messageBuffer = null;
      _lengthBuffer.rewind();
      Completer completer = _replyCompleters.remove(reply.responseTo);
      if (completer != null){
        completer.complete(reply);
      }
      else {
        _log.shout("Unexpected respondTo: ${reply.responseTo} ${reply.documents[0]}");
      }
    }
  }


  Future<MongoReplyMessage> query(MongoMessage queryMessage){
    Completer completer = new Completer();
    _replyCompleters[queryMessage.requestId] = completer;
    socket.onData = _receiveData;
    _sendQueue.addLast(queryMessage);
    _sendBuffer();
    return completer.future;
  }
  void execute(MongoMessage mongoMessage){
    _sendQueue.addLast(mongoMessage);
    _sendBuffer();
  }
}
