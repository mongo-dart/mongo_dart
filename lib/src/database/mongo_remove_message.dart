part of mongo_dart;

class MongoRemoveMessage extends MongoMessage {
  BsonCString _collectionFullName;
  int flags;
  BsonMap _selector;

  MongoRemoveMessage(String collectionFullName,
      [Map selector = const {}, this.flags = 0]) {
    _collectionFullName = new BsonCString(collectionFullName);
    _selector = new BsonMap(selector);
    opcode = MongoMessage.Delete;
  }

  int get messageLength {
    return 16 +
        4 +
        _collectionFullName.byteLength() +
        4 +
        _selector.byteLength();
  }

  BsonBinary serialize() {
    BsonBinary buffer = new BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(flags);
    _selector.packValue(buffer);
    buffer.offset = 0;
    return buffer;
  }

  String toString() {
    return "MongoRemoveMessage($requestId, ${_collectionFullName.value}, ${_selector.value})";
  }
}
