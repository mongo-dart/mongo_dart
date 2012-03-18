class MongoMessage{
  static final Reply = 1;
  static final Message = 1000;
  static final Update = 2001;
  static final Insert = 2002;
  static final Query = 2004;
  static final GetMore = 2005;
  static final Delete = 2006;
  static final KillCursors = 2007;   
  int _messageLength;
  int _requestId;
  int get requestId(){
    if (_requestId === null){
      _requestId = Statics.nextRequestId;    
    }
    return _requestId;      
  }
  int responseTo;
  int opcode = MongoMessage.Reply;
  int get messageLength(){
    throw "Must be implemented";
  }
  Binary serialize(){
    throw "Must be implemented";    
  }  
  MongoMessage deserialize(Binary buffer){
    throw "Must be implemented";    
  }  
  readMessageHeaderFrom(Binary buffer)
  {
      _messageLength = buffer.readInt32();
      _requestId = buffer.readInt32();
      responseTo = buffer.readInt32();
      if (buffer.readInt32() != opcode)
      {
          throw "Message header opcode is not the expected one.";
      }
  }

  writeMessageHeaderTo(Binary buffer)
  {
      buffer.writeInt(messageLength); // messageLength will be backpatched later
      buffer.writeInt(requestId);
      buffer.writeInt(0); // responseTo not used in requests sent by client
      buffer.writeInt(opcode);
      if (messageLength < 0){
        throw "Error in message length";
      }
  }
  String toString(){
    throw "must be implemented";
  }

}