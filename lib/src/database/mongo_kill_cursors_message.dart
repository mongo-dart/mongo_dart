part of mongo_dart;

class MongoKillCursorsMessage extends MongoMessage {
  int cursorId;

  MongoKillCursorsMessage(this.cursorId) {
    opcode = MongoMessage.KillCursors;
  }

  @override
  int get messageLength {
    return 16 + 4 + 4 + 8;
  }

  @override
  BsonBinary serialize() {
    var buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    buffer.writeInt(1);
    buffer.writeInt64(cursorId);
    buffer.offset = 0;
    return buffer;
  }

  @override
  String toString() {
    return 'MongoKillCursorsMessage($requestId, $cursorId)';
  }
}
