class SocketOptions{
  String host;
  int port;  
  SocketOptions([this.host='127.0.0.1', this.port=27017]);
}
class Connection{
  Binary lengthBuffer;
  SocketOptions socketOptions;
  Binary messageBuffer;
  Socket socket;
  var completeCallback;
  Connection(){
    socketOptions = new SocketOptions();
  }
  connect(){
    socket = new Socket(socketOptions.host, socketOptions.port);
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
      print(messageLength);
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
      completeCallback(reply);
    }   
  }
  query(MongoQueryMessage queryMessage, callback){
    completeCallback = callback;
    Binary buffer = queryMessage.serialize();  
    socket.onError = ()=>print("Socket error");  
    socket.onData = receiveData;
    sendData(buffer);
  }
}
