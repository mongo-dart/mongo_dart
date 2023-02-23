import 'package:bson/bson.dart' show BsonBinary, BsonCString, BsonMap;
import 'package:mongo_dart/src/database/document_types.dart';

abstract class Payload {
  void packValue(BsonBinary buffer);

  int get byteLength;

  Map<String, dynamic> get content;
}

class Payload0 extends Payload {
  BsonMap document;

  Payload0(MongoDocument document) : document = BsonMap(document);

  Payload0.fromBuffer(BsonBinary buffer)
      : document = BsonMap.fromBuffer(buffer);

  @override
  void packValue(BsonBinary buffer) => document.packValue(buffer);

  @override
  int get byteLength => document.byteLength();

  @override
  Map<String, dynamic> get content => document.data;
}

class Payload1 extends Payload {
  int? _length;
  final BsonCString identifier;
  late List<BsonMap> _documents;

  Payload1(String identifier, List<Map<String, dynamic>> documents)
      : identifier = BsonCString(identifier),
        _documents = _createBsonMapList(documents);

  Payload1.fromBuffer(BsonBinary buffer)
      : _length = (buffer /* ..makeByteList() */).readInt32(),
        identifier = BsonCString(buffer.readCString()) {
    _documents =
        _decodeBsonMapList(buffer, _length! - 4 - identifier.byteLength());
  }

  @override
  int get byteLength => _length ??=
      4 /* sequence length */ + identifier.byteLength() + documentsByteLength;

  int get documentsByteLength {
    var len = 0;
    for (var doc in _documents) {
      len += doc.byteLength();
    }
    return len;
  }

  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteLength);
    identifier.packValue(buffer);
    for (var data in _documents) {
      data.packValue(buffer);
    }
  }

  @override
  Map<String, Object> get content =>
      {identifier.data: _extractBsonMapList(_documents)};
}

List<BsonMap> _createBsonMapList(List<Map<String, dynamic>> documents) {
  var locDocuments = <BsonMap>[];
  for (var document in documents) {
    locDocuments.add(BsonMap(document));
  }
  return locDocuments;
}

List<Map<String, Object>> _extractBsonMapList(List<BsonMap> documents) {
  var locDocuments = <Map<String, Object>>[];
  for (var document in documents) {
    locDocuments.add(document.data as Map<String, Object>);
  }
  return locDocuments;
}

List<BsonMap> _decodeBsonMapList(BsonBinary buffer, int length) {
  var locDocuments = <BsonMap>[];
  while (length > 0) {
    var map = BsonMap.fromBuffer(buffer);
    locDocuments.add(map);
    length -= map.byteLength();
  }

  return locDocuments;
}
