import 'package:bson/bson.dart' show BsonBinary;
// ignore: implementation_imports
import 'package:bson/src/types/bson_map.dart';
// ignore: implementation_imports
import 'package:bson/src/types/bson_string.dart';

abstract class Payload {
  void packValue(BsonBinary buffer);

  int get byteLength;

  Map<String, Object?> get content;
}

class Payload0 extends Payload {
  BsonMap document;

  Payload0(Map<String, Object> document) : document = BsonMap(document);

  Payload0.fromBuffer(BsonBinary buffer)
      : document = BsonMap.fromBuffer(buffer);

  @override
  void packValue(BsonBinary buffer) => document.packValue(buffer);

  @override
  int get byteLength => document.totalByteLength;

  @override
  Map<String, Object?> get content => document.value;
}

class Payload1 extends Payload {
  int? _length;
  final BsonCString identifier;
  late List<BsonMap> _documents;

  Payload1(String identifier, List<Map<String, Object?>> documents)
      : identifier = BsonCString(identifier),
        _documents = _createBsonMapList(documents);

  Payload1.fromBuffer(BsonBinary buffer)
      : _length = (buffer /* ..makeByteList() */).readInt32(),
        identifier = BsonCString(buffer.readCString()) {
    _documents =
        _decodeBsonMapList(buffer, _length! - 4 - identifier.totalByteLength);
  }

  @override
  int get byteLength => _length ??= 4 /* sequence length */ +
      identifier.totalByteLength +
      documentsByteLength;

  int get documentsByteLength {
    var len = 0;
    for (var doc in _documents) {
      len += doc.totalByteLength;
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

List<BsonMap> _createBsonMapList(List<Map<String, Object?>> documents) {
  var locDocuments = <BsonMap>[];
  for (var document in documents) {
    locDocuments.add(BsonMap(document));
  }
  return locDocuments;
}

List<Map<String, Object>> _extractBsonMapList(List<BsonMap> documents) {
  var locDocuments = <Map<String, Object>>[];
  for (var document in documents) {
    locDocuments.add(document.value as Map<String, Object>);
  }
  return locDocuments;
}

List<BsonMap> _decodeBsonMapList(BsonBinary buffer, int length) {
  var locDocuments = <BsonMap>[];
  while (length > 0) {
    var map = BsonMap.fromBuffer(buffer);
    locDocuments.add(map);
    length -= map.totalByteLength;
  }

  return locDocuments;
}
