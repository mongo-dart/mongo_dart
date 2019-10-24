part of mongo_dart;

class MongoMessageHandler {
  final _log = Logger('MongoMessageTransformer');
  final converter = PacketConverter();

  void handleData(Uint8List data, EventSink<MongoReplyMessage> sink) {
    converter.addPacket(data);
    while (!converter.messages.isEmpty) {
      var buffer = BsonBinary.from(converter.messages.removeFirst());
      MongoReplyMessage reply = MongoReplyMessage();
      reply.deserialize(buffer);
      _log.fine(() => reply.toString());
      sink.add(reply);
    }
  }

  void handleDone(EventSink<MongoReplyMessage> sink) {
    if (!converter.isClear) {
      _log.warning(
          'Invalid state of PacketConverter in handleDone: $converter');
    }
    sink.close();
  }

  StreamTransformer<Uint8List, MongoReplyMessage> get transformer =>
      new StreamTransformer<Uint8List, MongoReplyMessage>.fromHandlers(
          handleData: handleData, handleDone: handleDone);
}
