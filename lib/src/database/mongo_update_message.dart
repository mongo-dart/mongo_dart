part of mongo_dart;

class MongoUpdateMessage extends MongoMessage {
  BsonCString _collectionFullName;
  int flags;
  int numberToSkip;
  int numberToReturn;
  BsonMap _selector;
  BsonMap _document;

  MongoUpdateMessage(String collectionFullName, Map<String, dynamic> selector,
      document, this.flags) {
    _collectionFullName = BsonCString(collectionFullName);
    _selector = BsonMap(selector);
    if (document is ModifierBuilder) {
      document = document.map;
    }
    _document = BsonMap(document as Map<String, dynamic>);
    opcode = MongoMessage.Update;
  }

  @override
  int get messageLength {
    return 16 +
        4 +
        _collectionFullName.byteLength() +
        4 +
        _selector.byteLength() +
        _document.byteLength();
  }

  @override
  BsonBinary serialize() {
    var buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(flags);
    _selector.packValue(buffer);
    _document.packValue(buffer);
    buffer.offset = 0;
    return buffer;
  }

  @override
  String toString() {
    return 'MongoUpdateMessage($requestId, ${_collectionFullName.value}, ${_selector.value}, ${_document.value})';
  }
}
