part of '../../mongo_dart.dart';

class MongoInsertMessage extends MongoMessage {
  final BsonCString _collectionFullName;
  int flags;
  final List<BsonMap> _documents;
  MongoInsertMessage(
      String collectionFullName, List<Map<String, dynamic>> documents,
      [this.flags = 0])
      : _collectionFullName = BsonCString(collectionFullName),
        _documents = <BsonMap>[] {
    for (var document in documents) {
      _documents.add(BsonMap(document));
    }
    opcode = MongoMessage.insert;
  }

  @override
  int get messageLength {
    var docsSize = 0;
    for (var doc in _documents) {
      docsSize += doc.totalByteLength;
    }
    var result = 16 + 4 + _collectionFullName.totalByteLength + docsSize;
    return result;
  }

  @override
  BsonBinary serialize() {
    var buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(flags);
    _collectionFullName.packValue(buffer);
    for (var doc in _documents) {
      doc.packValue(buffer);
    }
    buffer.offset = 0;
    return buffer;
  }

  @override
  String toString() {
    if (_documents.length == 1) {
      return 'MongoInserMessage($requestId, '
          '${_collectionFullName.value}, ${_documents[0].value})';
    }
    return 'MongoInserMessage($requestId, '
        '${_collectionFullName.value}, ${_documents.length} documents)';
  }
}
