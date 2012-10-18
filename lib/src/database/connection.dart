part of mongo_dart;
class Connection{
  Map<int,Completer<MongoReplyMessage>> replyCompleters;
  BsonBinary lengthBuffer;
  ServerConfig serverConfig;
  BsonBinary bufferToSend;
  Queue<MongoMessage> sendQueue;
  BsonBinary messageBuffer;
  Socket socket;
  bool connected = false;
  Connection([this.serverConfig]){
    if (serverConfig === null){
      serverConfig = new ServerConfig();
    }    
  }
  Future<bool> connect(){
    replyCompleters = new Map();
    sendQueue = new Queue();
    socket = new Socket(serverConfig.host, serverConfig.port);
    Completer completer = new Completer();
    if (socket is! Socket) {
      completer.completeException(new Exception( "can't get send socket"));
    } else {
      lengthBuffer = new BsonBinary(4);
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
  close(){
    while (!sendQueue.isEmpty()){
      sendBuffer("From close");
    }
    socket.onData = null;
    socket.onWrite = null;
    socket.onError = null;
    sendQueue.clear();
    socket.close();
    replyCompleters.clear();    
  }
  getNextBufferToSend(){
    if (bufferToSend === null || bufferToSend.atEnd()){
      if(!sendQueue.isEmpty()){
        MongoMessage message = sendQueue.removeFirst();
        debug(message.toString());
        bufferToSend = message.serialize();
        debug(bufferToSend.hexString);
      } else {
        bufferToSend = null;  
      } 
    }
  }
  sendBufferFromTimer() => sendBuffer("from Timer");
  sendBufferFromOnWrite() => sendBuffer("from OnWrite");
  sendBuffer(String origin){
    debug("sendBuffer($origin)");
    getNextBufferToSend();
    if (bufferToSend !== null){      
      bufferToSend.offset += socket.writeList(bufferToSend.byteList,
        bufferToSend.offset,bufferToSend.byteList.length-bufferToSend.offset);
      if (!bufferToSend.atEnd()){        
       debug("Buffer not send fully, offset: ${bufferToSend.offset}");
      }
      
      new Timer(0,(t)=>sendBufferFromTimer());              
    }        
    else {
      socket.onWrite = null;        
    }    
  }  
   void receiveData() {
    if (messageBuffer === null){
      int numBytes = socket.readList(lengthBuffer.byteList, 0, 4);
      if (numBytes == 0) {
        return;
      }
      int messageLength = lengthBuffer.readInt32();      
      messageBuffer = new BsonBinary(messageLength);
      messageBuffer.writeInt(messageLength);
    }
    messageBuffer.offset += socket.readList(messageBuffer.byteList,messageBuffer.offset,messageBuffer.byteList.length-messageBuffer.offset);
    if (messageBuffer.atEnd()){
      MongoReplyMessage reply = new MongoReplyMessage();
      messageBuffer.rewind();
      reply.deserialize(messageBuffer);
      debug(reply.toString());
      messageBuffer = null;
      lengthBuffer.rewind();
      Completer completer = replyCompleters.remove(reply.responseTo);      
      if (completer !== null){    
        completer.complete(reply);       
      }
      else {
        warn("Unexpected respondTo: ${reply.responseTo} ${reply.documents[0]}");
      }  
    }   
  }
  Future<MongoReplyMessage> query(MongoMessage queryMessage){
    Completer completer = new Completer();
    replyCompleters[queryMessage.requestId] = completer;
    socket.onData = receiveData;
    sendQueue.addLast(queryMessage);
    socket.onWrite = sendBufferFromOnWrite;    
    return completer.future;
  }
}
