import 'package:mongo_dart/mongo_dart_old.dart' show BsonBinary;

import '../../../src/core/error/mongo_dart_error.dart';
import '../../../src/core/message/abstract/mongo_message.dart';

class MongoResponseMessage extends MongoMessage {
  MongoMessage deserialize(BsonBinary buffer) {
    throw MongoDartError('Must be implemented');
  }

  static int extractOpcode(BsonBinary buffer) {
    buffer.readInt32();
    buffer.readInt32();
    buffer.readInt32();
    var opcodeFromWire = buffer.readInt32();
    buffer.offset -= 16;
    return opcodeFromWire;
  }
}
