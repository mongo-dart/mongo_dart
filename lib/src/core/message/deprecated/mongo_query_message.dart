// ignore_for_file: non_constant_identifier_names

import 'package:bson/bson.dart';
import 'package:meta/meta.dart';

import '../abstract/mongo_message.dart';

class MongoQueryMessage extends MongoMessage {
  static final OPTS_NONE = 0;
  static final OPTS_TAILABLE_CURSOR = 2;
  static final OPTS_SLAVE = 4;
  static final OPTS_OPLOG_REPLY = 8;
  static final OPTS_NO_CURSOR_TIMEOUT = 16;
  static final OPTS_AWAIT_DATA = 32;
  static final OPTS_EXHAUST = 64;
  static final OPTS_PARTIAL = 128;

  @protected
  BsonCString? collFullName;
  int flags;
  int numberToSkip;
  int numberToReturn;
  late BsonMap _query;
  BsonMap? _fields;
  BsonCString? get collectionNameBson => collFullName;

  MongoQueryMessage(
      String? collectionFullName,
      this.flags,
      this.numberToSkip,
      this.numberToReturn,
      Map<String, dynamic> query,
      Map<String, dynamic>? fields) {
    if (collectionFullName != null) {
      collFullName = BsonCString(collectionFullName);
    }
    _query = BsonMap(query);
    if (fields != null) {
      _fields = BsonMap(fields);
    }
    opcode = MongoMessage.query;
  }

  @override
  int get messageLength {
    var result = 16 +
        4 +
        (collFullName?.byteLength() ?? 0) +
        4 +
        4 +
        _query.byteLength();
    if (_fields != null) {
      result += _fields!.byteLength();
    }
    return result;
  }

  @override
  BsonBinary serialize() {
    var buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(flags);
    collFullName?.packValue(buffer);
    buffer.writeInt(numberToSkip);
    buffer.writeInt(numberToReturn);
    _query.packValue(buffer);
    if (_fields != null) {
      _fields!.packValue(buffer);
    }
    buffer.offset = 0;
    return buffer;
  }

  @override
  String toString() => 'MongoQueryMessage($requestId, '
      '${collFullName?.value ?? ''},numberToReturn:$numberToReturn, '
      '${_query.value})';
}
