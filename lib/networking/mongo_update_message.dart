class MongoUpdateMessage extends MongoMessage{
  BsonCString _collectionFullName;
  int flags;
  int numberToSkip;
  int numberToReturn;
  BsonMap _query;
  BsonMap _fields;
  MongoUpdateMessage(String collectionFullName,
            this.flags,
            this.numberToSkip,
            this.numberToReturn,
            Map query,
            Map fields){
    _collectionFullName = new BsonCString(collectionFullName);
    _query = new BsonMap(query);
    if (fields !== null){
      _fields = new BsonMap(fields);
    }
    opcode = MongoMessage.Query;    
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