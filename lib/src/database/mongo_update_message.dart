part of mongo_dart;

class MongoUpdateMessage extends MongoMessage {
  BsonCString _collectionFullName;
  int flags;
  int numberToSkip;
  int numberToReturn;
  BsonMap _selector;
  BsonMap _document;

  MongoUpdateMessage(
      String collectionFullName, Map selector, document, this.flags) {
    _collectionFullName = new BsonCString(collectionFullName);
    _selector = new BsonMap(selector);
    if (document is ModifierBuilder) {
      document = document.map;
    }
    _document = new BsonMap(document);
    opcode = MongoMessage.Update;
  }

  int get messageLength {
    return 16 +
        4 +
        _collectionFullName.byteLength() +
        4 +
        _selector.byteLength() +
        _document.byteLength();
  }

  BsonBinary serialize() {
    BsonBinary buffer = new BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(flags);
    _selector.packValue(buffer);
    _document.packValue(buffer);
    buffer.offset = 0;
    return buffer;
  }

  String toString() {
    return "MongoUpdateMessage($requestId, ${_collectionFullName.value}, ${_selector.value}, ${_document.value})";
  }
}
