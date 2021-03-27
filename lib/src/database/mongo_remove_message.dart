part of mongo_dart;

class MongoRemoveMessage extends MongoMessage {
  final BsonCString _collectionFullName;
  int flags;
  final BsonMap _selector;

  MongoRemoveMessage(String collectionFullName,
      [Map<String, dynamic> selector = const {}, this.flags = 0])
      : _collectionFullName = BsonCString(collectionFullName),
        _selector = BsonMap(selector) {
    opcode = MongoMessage.Delete;
  }

  @override
  int get messageLength {
    return 16 +
        4 +
        _collectionFullName.byteLength() +
        4 +
        _selector.byteLength();
  }

  @override
  BsonBinary serialize() {
    var buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(flags);
    _selector.packValue(buffer);
    buffer.offset = 0;
    return buffer;
  }

  @override
  String toString() => 'MongoRemoveMessage($requestId, '
      '${_collectionFullName.value}, ${_selector.value})';
}
