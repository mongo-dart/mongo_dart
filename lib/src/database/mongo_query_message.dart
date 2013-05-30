part of mongo_dart;
class MongoQueryMessage extends MongoMessage{
static final OPTS_NONE = 0;
static final OPTS_TAILABLE_CURSOR = 2;
static final OPTS_SLAVE = 4;
static final OPTS_OPLOG_REPLY = 8;
static final OPTS_NO_CURSOR_TIMEOUT = 16;
static final OPTS_AWAIT_DATA = 32;
static final OPTS_EXHAUST = 64;


  BsonCString _collectionFullName;
  int flags;
  int numberToSkip;
  int numberToReturn;
  BsonMap _query;
  BsonMap _fields;
  BsonCString get collectionNameBson => _collectionFullName;
  MongoQueryMessage(String collectionFullName,
            this.flags,
            this.numberToSkip,
            this.numberToReturn,
            Map query,
            Map fields){
    _collectionFullName = new BsonCString(collectionFullName);
    _query = new BsonMap(query);
    if (fields != null){
      _fields = new BsonMap(fields);
    }
    opcode = MongoMessage.Query;
  }
  int get messageLength{
    int result = 16+4+_collectionFullName.byteLength()+4+4+_query.byteLength();
    if (_fields != null){
      result += _fields.byteLength();
    }
    return result;
  }
  BsonBinary serialize(){
    BsonBinary buffer = new BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(flags);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(numberToSkip);
    buffer.writeInt(numberToReturn);
    _query.packValue(buffer);
    if (_fields != null){
      _fields.packValue(buffer);
    }
    buffer.offset = 0;
    return buffer;
  }
  String toString(){
    return "MongoQueryMessage($requestId, ${_collectionFullName.value},numberToReturn:$numberToReturn, ${_query.value})";
  }
}