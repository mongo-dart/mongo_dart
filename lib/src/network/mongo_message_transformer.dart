part of mongo_dart;

class MongoMessageHandler {
  final _log = new Logger('MongoMessageTransformer');
  final converter = new PacketConverter();

  void handleData(Uint8List data, EventSink<MongoReplyMessage> sink) {
    converter.addPacket(data);
    while (!converter.messages.isEmpty) {
      var buffer = new BsonBinary.from(converter.messages.removeFirst());
      MongoReplyMessage reply = new MongoReplyMessage();
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
