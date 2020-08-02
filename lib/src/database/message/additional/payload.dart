import 'package:bson/bson.dart' show BsonBinary, BsonCString, BsonMap;

abstract class Payload {
  void packValue(BsonBinary buffer);

  int get byteLength;

  Map<String, Object> get content;
}

class Payload0 extends Payload {
  BsonMap document;

  Payload0(Map<String, Object> document) : document = BsonMap(document);

  Payload0.fromBuffer(BsonBinary buffer)
      : document = BsonMap(<String, Object>{})
          ..unpackValue(buffer..makeByteList());

  @override
  void packValue(BsonBinary buffer) => document.packValue(buffer);

  @override
  int get byteLength => document.byteLength();

  @override
  Map<String, Object> get content => document.data;
}

class Payload1 extends Payload {
  int _length;
  final BsonCString identifier;
  List<BsonMap> _documents;

  Payload1(String identifier, List<Map<String, Object>> documents)
      : identifier = BsonCString(identifier),
        _documents = _createBsonMapList(documents);

  Payload1.fromBuffer(BsonBinary buffer)
      : _length = (buffer..makeByteList()).readInt32(),
        identifier = BsonCString(buffer.readCString()) {
    _documents =
        _decodeBsonMapList(buffer, _length - 4 - identifier.byteLength());
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

List<BsonMap> _createBsonMapList(List<Map<String, Object>> documents) {
  var _documents = <BsonMap>[];
  for (var document in documents) {
    _documents.add(BsonMap(document));
  }
  return _documents;
}

List<Map<String, Object>> _extractBsonMapList(List<BsonMap> documents) {
  var _documents = <Map<String, Object>>[];
  for (var document in documents) {
    _documents.add(document.data);
  }
  return _documents;
}

List<BsonMap> _decodeBsonMapList(BsonBinary buffer, int length) {
  var _documents = <BsonMap>[];
  while (length > 0) {
    var map = BsonMap(<String, Object>{});
    map.unpackValue(buffer);
    _documents.add(map);
    length -= map.byteLength();
  }

  return _documents;
}
