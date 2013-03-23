part of mongo_dart;
class Connection{
  final _replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  final _recievedResponses = new Set<int>();
  final _sentQueries = new Map<int,MongoMessage>(); 
  final _sentCommands = new Set<int>(); 
  BsonBinary _lengthBuffer;
  ServerConfig serverConfig;
  BsonBinary _bufferToSend;
  final _sendQueue = new Queue<MongoMessage>();
  BsonBinary _messageBuffer;
  Socket socket;
  List _incompleteLengthBytes = [];
  StreamSubscription<List<int>> _socketSubscription;
  bool connected = false;
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
        print("connect exception ${e}");
        completer.completeError(e);
      });
      connected = true;
      completer.complete(true);
    });
    return completer.future;
  }
  
  void close(){
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
      socket.writeBytes(_bufferToSend.byteList);
    }
  }
  void _receiveData(List<int> data, [int offset = 0, int recursion = 0]) {
    if (_messageBuffer == null){
      if (data.length - offset < 4) {
        _incompleteLengthBytes = data.sublist(offset);
        return;
      }
      _lengthBuffer.byteList.setRange(0, _incompleteLengthBytes.length, _incompleteLengthBytes, offset);     
      _lengthBuffer.byteList.setRange(0 + _incompleteLengthBytes.length, 4 - _incompleteLengthBytes.length, data, offset);
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
    //print('offset:$offset delta:$delta data.length:${data.length} message.lenght:${_messageBuffer.byteList.length}');
    //***** temporary safety hatch
    if (recursion > 200) {
      throw 'Maybe we in infinite recursion? $data';
    }
    _messageBuffer.byteList.setRange(_messageBuffer.offset, delta , data, offset);
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
        _recievedResponses.add(reply.responseTo);
        completer.complete(reply);
      }
      else {
        var recievedBefore = _recievedResponses.contains(reply.responseTo);
        var inCommands = _sentCommands.contains(reply.responseTo);
        var respondedTo = _sentQueries[reply.responseTo];
//        print("Unexpected respondTo: ${reply.responseTo} recievedBefore:$recievedBefore inCommands:$inCommands respondedTo:$respondedTo $reply $_replyCompleters");
        _log.fine("Unexpected respondTo: ${reply.responseTo} $reply");
      }
      if (delta + offset < data.length) {
//        print('delta:$delta offset:$offset length:${data.length} data:$data');
        _receiveData(data, delta + offset, recursion + 1); 
      }  
    }
  }
  Future<MongoReplyMessage> query(MongoMessage queryMessage){
    Completer completer = new Completer();
    _replyCompleters[queryMessage.requestId] = completer;
    _sentQueries[queryMessage.requestId] = queryMessage;
    _sendQueue.addLast(queryMessage);
    _sendBuffer();
    return completer.future;
  }
  void execute(MongoMessage mongoMessage){
    _sentCommands.add(mongoMessage.requestId);
    _sendQueue.addLast(mongoMessage);
    _sendBuffer();
  }
}
