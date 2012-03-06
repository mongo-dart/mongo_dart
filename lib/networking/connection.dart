class Connection{
  Binary lengthBuffer;
  ServerConfig serverConfig;
  Binary messageBuffer;
  Socket socket;
  Completer replyCompleter;
  Connection([this.serverConfig]){
    if (serverConfig === null){
      serverConfig = new ServerConfig();
    }    
  }
  connect(){
    socket = new Socket(serverConfig.host, serverConfig.port);
    if (socket == null) {
      throw "can't get send socket";
    }
    lengthBuffer = new Binary(4);
  }
  int sendData(Binary msg){
    while (msg.offset != msg.bytes.length){
      msg.offset += socket.writeList(msg.bytes,msg.offset,msg.bytes.length-msg.offset);
    }    
    return msg.offset;
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
      socket.onData = null;
      socket.onError = null;
      MongoReplyMessage reply = new MongoReplyMessage();
      messageBuffer.rewind();
      reply.deserialize(messageBuffer);
      replyCompleter.complete(reply);
    }   
  }
  Future<Map> query(MongoQueryMessage queryMessage){
    replyCompleter = new Completer();    
    Binary buffer = queryMessage.serialize();      
    socket.onData = receiveData;
    sendData(buffer);
    return replyCompleter.future;
  }
}
