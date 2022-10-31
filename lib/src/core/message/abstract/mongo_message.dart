import 'package:bson/bson.dart';

import '../../error/mongo_dart_error.dart';

int _requestId = 0;

abstract class MongoMessage {
  // Todo adjust the following constants
  static final reply = 1;
  static final message = 1000;
  static final update = 2001;
  static final insert = 2002;
  static final query = 2004;
  static final getMore = 2005;
  static final delete = 2006;
  static final killCursors = 2007;
  static final modernMessage = 2013;

  final int requestId = ++_requestId;
  int _messageLength = 0;

  int get messageLength => _messageLength;

  int responseTo = 0;
  int opcode = MongoMessage.reply;

  BsonBinary serialize() => throw MongoDartError('Must be implemented');

  void readMessageHeaderFrom(BsonBinary buffer) {
    _messageLength = buffer.readInt32();
    _requestId = buffer.readInt32();
    responseTo = buffer.readInt32();
    var opcodeFromWire = buffer.readInt32();
    if (opcodeFromWire != opcode) {
      throw MongoDartError(
          'Expected $opcode in Message header. Got $opcodeFromWire');
    }
  }

  void writeMessageHeaderTo(BsonBinary buffer) {
    buffer.writeInt(messageLength); // messageLength will be backpatched later
    buffer.writeInt(requestId);
    buffer.writeInt(0); // responseTo not used in requests sent by client
    buffer.writeInt(opcode);
    if (messageLength < 0) {
      throw MongoDartError('Error in message length');
    }
  }

  @override
  String toString() => throw MongoDartError('must be implemented');
}
