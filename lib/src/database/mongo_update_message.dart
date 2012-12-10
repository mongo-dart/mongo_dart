part of mongo;

class MongoUpdateMessage extends MongoMessage{
  BsonCString _collectionFullName;
  int flags;
  int numberToSkip;
  int numberToReturn;
  BsonMap _selector;
  BsonMap _document;
  MongoUpdateMessage(String collectionFullName,
            Map selector,
            Map document,
            this.flags
            ){
    _collectionFullName = new BsonCString(collectionFullName);
    _selector = new BsonMap(selector);
    _document = new BsonMap(document);
    opcode = MongoMessage.Update;
  }
  int get messageLength{
    return 16+4+_collectionFullName.byteLength()+4+_selector.byteLength()+_document.byteLength();
  }
  Binary serialize(){
    Binary buffer = new Binary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(flags);
    _selector.packValue(buffer);
    _document.packValue(buffer);
    buffer.offset = 0;
    return buffer;
  }
  String toString(){
    return "MongoUpdateMessage($requestId, ${_collectionFullName.value}, ${_selector.value}, ${_document.value})";
  }

}