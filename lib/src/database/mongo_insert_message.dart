part of mongo_dart;

class MongoInsertMessage extends MongoMessage {
  BsonCString _collectionFullName;
  int flags;
  List<BsonMap> _documents;
  MongoInsertMessage(
      String collectionFullName, List<Map<String, dynamic>> documents,
      [this.flags = 0]) {
    _collectionFullName = BsonCString(collectionFullName);
    _documents = List();
    for (var document in documents) {
      _documents.add(BsonMap(document));
    }
    opcode = MongoMessage.Insert;
  }

  int get messageLength {
    int docsSize = 0;
    for (var _doc in _documents) {
      docsSize += _doc.byteLength();
    }
    int result = 16 + 4 + _collectionFullName.byteLength() + docsSize;
    return result;
  }

  BsonBinary serialize() {
    BsonBinary buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(flags);
    _collectionFullName.packValue(buffer);
    for (var _doc in _documents) {
      _doc.packValue(buffer);
    }
    buffer.offset = 0;
    return buffer;
  }

  String toString() {
    if (_documents.length == 1) {
      return "MongoInserMessage($requestId, ${_collectionFullName.value}, ${_documents[0].value})";
    }
    return "MongoInserMessage($requestId, ${_collectionFullName.value}, ${_documents.length} documents)";
  }
}
