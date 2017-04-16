part of mongo_dart;

class _Statics {
  static int _requestId;
  static int get nextRequestId {
    if (_requestId == null) {
      _requestId = 1;
    }

    return ++_requestId;
  }
}

class MongoMessage {
  static final Reply = 1;
  static final Message = 1000;
  static final Update = 2001;
  static final Insert = 2002;
  static final Query = 2004;
  static final GetMore = 2005;
  static final Delete = 2006;
  static final KillCursors = 2007;
  int _requestId;
  int _messageLength;
  int get messageLength => _messageLength;
  int get requestId {
    if (_requestId == null) {
      _requestId = _Statics.nextRequestId;
    }

    return _requestId;
  }

  int responseTo;
  int opcode = MongoMessage.Reply;

  BsonBinary serialize() {
    throw new MongoDartError('Must be implemented');
  }

  MongoMessage deserialize(BsonBinary buffer) {
    throw new MongoDartError('Must be implemented');
  }

  readMessageHeaderFrom(BsonBinary buffer) {
    _messageLength = buffer.readInt32();
    _requestId = buffer.readInt32();
    responseTo = buffer.readInt32();
    int opcodeFromWire = buffer.readInt32();
    if (opcodeFromWire != opcode) {
      throw new MongoDartError(
          'Expected $opcode in Message header. Got $opcodeFromWire');
    }
  }

  writeMessageHeaderTo(BsonBinary buffer) {
    buffer.writeInt(messageLength); // messageLength will be backpatched later
    buffer.writeInt(requestId);
    buffer.writeInt(0); // responseTo not used in requests sent by client
    buffer.writeInt(opcode);
    if (messageLength < 0) {
      throw new MongoDartError('Error in message length');
    }
  }

  String toString() {
    throw new MongoDartError('must be implemented');
  }
}
