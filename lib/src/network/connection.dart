part of mongo_dart;
class _Connection{
  final _log= new Logger('Connection'); 
  static const int HEADER_SIZE = 16;
  final _replyCompleters = new Map<int,Completer<MongoReplyMessage>>();
  final Buffer _headerBuffer = new Buffer(HEADER_SIZE);
  Buffer _dataBuffer;
  ServerConfig serverConfig;
  BsonBinary _bufferToSend;
  BsonBinary _messageBinary;
  BufferedSocket socket;
  List _incompleteLengthBytes = [];
  final _sendQueue = new Queue<MongoMessage>();
  StreamSubscription<List<int>> _socketSubscription;
  bool connected = false;
  bool _closing = false;
  bool _readyForHeader = true;
  _Connection([this.serverConfig]) {
    if (serverConfig == null){
      serverConfig = new ServerConfig();
    }
  }
  Future<bool> connect(){
    Completer completer = new Completer();
    _log.fine("opening connection to ${serverConfig.host}:${serverConfig.port}");
    BufferedSocket.connect(serverConfig.host, serverConfig.port,
      onDataReady: _readPacket,
      onDone: () {
        release();
        _log.fine("done");
      },      
      onError: (error) {
        _log.info("error $error");
        release();
        completer.completeError(error);
      }).then((_socket) {
      _log.fine('Got socket $_socket');  
      socket = _socket;
      connected = true;
      completer.complete(true);
    });
    return completer.future;
  }
  
  void release(){
    _closing = true;
    if (socket != null) {
      socket.close();
    }  
    _replyCompleters.clear();
  }
  _sendBuffer(){
    _log.fine('_sendBuffer ${!_sendQueue.isEmpty} ${socket.readyToWrite}');
    if (!_sendQueue.isEmpty && socket.readyToWrite) {
      var mongoMessage = _sendQueue.removeFirst();
      socket.writeBuffer(new Buffer.fromList(mongoMessage.serialize().byteList))
        .then((_)=>_sendBuffer());
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
  
  void _readPacket() {
    _log.fine("readPacket readyForHeader=${_readyForHeader}");
    if (_readyForHeader) {
      _readyForHeader = false;
      socket.onDataReady = null;
      socket.readBuffer(_headerBuffer).then(_handleHeader);      
    }
  }
  void _handleHeader(Buffer buffer) {
    var binary = new BsonBinary.from(buffer.list);
    var header = new _MessageHeader();
    header.messageLength = binary.readInt32();
    header.requestID =  binary.readInt32();
    header.responseTo = binary.readInt32();
    header.opCode = binary.readInt32();
    _log.fine('Got header $header');
    _dataBuffer = new Buffer(header.messageLength - 16);
    _messageBinary = new BsonBinary(header.messageLength);
    _messageBinary.byteList.setRange(0, 16 , buffer.list);   
    socket.readBuffer(_dataBuffer).then(_handleData);
  }
  void _handleData(Buffer buffer) {
    _readyForHeader = true;
    socket.onDataReady = _readPacket;
    _headerBuffer.reset();
    _messageBinary.byteList.setRange(16, _messageBinary.byteList.length , buffer.list);    
    MongoReplyMessage reply = new MongoReplyMessage();
    _messageBinary.rewind();
    reply.deserialize(_messageBinary);
    _log.fine(reply.toString());
    _messageBinary = null;
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
