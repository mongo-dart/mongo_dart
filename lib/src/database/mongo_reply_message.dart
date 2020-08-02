part of mongo_dart;

class MongoReplyMessage extends MongoResponseMessage {
  static final FLAGS_CURSOR_NONE = 0;
  static final FLAGS_CURSOR_NOT_FOUND = 1;
  static final FLAGS_QUERY_FAILURE = 2;
  static final FLAGS_SHARD_CONFIGSTALE = 4;
  static final FLAGS_AWAIT_CAPABLE = 8;

  int responseFlags;
  int cursorId = -1; // 64bit integer
  int startingFrom;
  int numberReturned = -1;
  List<Map<String, dynamic>> documents;

  @override
  MongoMessage deserialize(BsonBinary buffer) {
    readMessageHeaderFrom(buffer);
    responseFlags = buffer.readInt32();
    cursorId = buffer.readInt64();
    startingFrom = buffer.readInt32();
    numberReturned = buffer.readInt32();
    documents = List(numberReturned);
    for (var n = 0; n < numberReturned; n++) {
      var doc = BsonMap({});
      doc.unpackValue(buffer);
      documents[n] = doc.value as Map<String, dynamic>;
    }
    return this;
  }

  @override
  String toString() {
    if (documents.length == 1) {
      return 'MongoReplyMessage(ResponseTo:$responseTo, cursorId: $cursorId, '
          'numberReturned:$numberReturned, responseFlags:$responseFlags, '
          '${documents[0]})';
    }
    return 'MongoReplyMessage(ResponseTo:$responseTo, cursorId: $cursorId, '
        'numberReturned:$numberReturned, responseFlags:$responseFlags, '
        '$documents)';
  }
}
