class MongoReplyMessage extends MongoMessage{
  BsonCString _collectionFullName;
  int responseFlags;
  // 64bit integer
  int cursorId =-1; 
  int startingFrom;
  int numberReturned = -1;
  List documents;  
  deserialize(Binary buffer){
    readMessageHeaderFrom(buffer);
    responseFlags = buffer.readInt32();
    cursorId = buffer.readInt64();
    startingFrom = buffer.readInt32();
    numberReturned = buffer.readInt32();
    documents = new List(numberReturned);
    for (int n=0;n<numberReturned;n++){
      BsonMap doc = new BsonMap({});
      doc.unpackValue(buffer);
      documents[n] = doc.value;
    }
  }
  int get messageLength(){
    int result = 16+4+_collectionFullName.byteLength()+4+4+_query.byteLength();
    if (_fields !== null){
      result += _fields.byteLength();
    }
    return result;
  }
  Binary serialize(){
    Binary buffer = new Binary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(flags);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(numberToSkip);
    buffer.writeInt(numberToReturn);
    _query.packValue(buffer);
    buffer.offset = 0;
    return buffer;
  }
}