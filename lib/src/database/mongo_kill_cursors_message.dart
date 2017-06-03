part of mongo_dart;

class MongoKillCursorsMessage extends MongoMessage {
  int cursorId;

  MongoKillCursorsMessage(this.cursorId) {
    opcode = MongoMessage.KillCursors;
  }

  int get messageLength {
    return 16 + 4 + 4 + 8;
  }

  BsonBinary serialize() {
    BsonBinary buffer = new BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(0);
    buffer.writeInt(1);
    buffer.writeInt64(cursorId);
    buffer.offset = 0;
    return buffer;
  }

  String toString() {
    return "MongoKillCursorsMessage($requestId, $cursorId)";
  }
}
