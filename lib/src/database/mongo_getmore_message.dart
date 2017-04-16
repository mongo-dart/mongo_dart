part of mongo_dart;

class MongoGetMoreMessage extends MongoMessage {
  BsonCString _collectionFullName;
  int cursorId;
  int numberToReturn;

  MongoGetMoreMessage(String collectionFullName, this.cursorId,
      [this.numberToReturn = 20]) {
    _collectionFullName = new BsonCString(collectionFullName);
    opcode = MongoMessage.GetMore;
  }

  int get messageLength {
    return 16 + 4 + _collectionFullName.byteLength() + 4 + 8;
  }

  BsonBinary serialize() {
    BsonBinary buffer = new BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    _collectionFullName.packValue(buffer);
    buffer.writeInt(numberToReturn);
    buffer.writeInt64(cursorId);
    buffer.offset = 0;
    return buffer;
  }

  String toString() {
    return "MongoGetMoreMessage($requestId, ${_collectionFullName.value}, $cursorId)";
  }
}
