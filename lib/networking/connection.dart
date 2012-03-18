class Connection{
  Map<int,Completer<MongoReplyMessage>> replyCompleters;
  Binary lengthBuffer;
  ServerConfig serverConfig;
  Binary bufferToSend;
  Queue<MongoMessage> sendQueue;
  Binary messageBuffer;
  Socket socket;  
  Connection([this.serverConfig]){
    if (serverConfig === null){
      serverConfig = new ServerConfig();
    }    
  }
  connect(){
    replyCompleters = new Map();
    sendQueue = new Queue();
    socket = new Socket(serverConfig.host, serverConfig.port);
    if (socket == null) {
      throw "can't get send socket";
    }
    lengthBuffer = new Binary(4);
  }
  close(){
    while (!sendQueue.isEmpty()){
      sendBuffer("From close");
    }
    socket.onData = null;
    socket.onWrite = null;
    socket.onError = null;
    socket.close();
    replyCompleters.clear();    
  }
  getNextBufferToSend(){
    if (bufferToSend === null || bufferToSend.atEnd()){
      if(!sendQueue.isEmpty()){
        MongoMessage message = sendQueue.removeFirst();
        debug(message.toString());
        bufferToSend = message.serialize();
      } else {
        bufferToSend = null;  
      } 
    }
  }
  sendBufferFromTimer() => sendBuffer("from Timer");
  sendBufferFromOnWrite() => sendBuffer("from OnWrite");
  sendBuffer(String origin){
    getNextBufferToSend();
    if (bufferToSend !== null){      
      bufferToSend.offset += socket.writeList(bufferToSend.bytes,
        bufferToSend.offset,bufferToSend.bytes.length-bufferToSend.offset);
      if (!bufferToSend.atEnd()){
//        print("Buffer not send fully, offset: ${bufferToSend.offset}");
      }
      new Timer(0,(t)=>sendBufferFromTimer());              
    }        
    else {
      socket.onWrite = null;        
    }    
  }  
   void receiveData() {
    if (messageBuffer === null){
      int numBytes = socket.readList(lengthBuffer.bytes, 0, 4);
      if (numBytes == 0) {
        return;
      }
      int messageLength = lengthBuffer.readInt32();      
      messageBuffer = new Binary(messageLength);
      messageBuffer.writeInt(messageLength);
    }
    messageBuffer.offset += socket.readList(messageBuffer.bytes,messageBuffer.offset,messageBuffer.bytes.length-messageBuffer.offset);
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
    sendBuffer("From query");
    return completer.future;
  }
  execute(MongoMessage message){
    sendQueue.addLast(message);    
    socket.onWrite = sendBufferFromOnWrite;
  }
}
