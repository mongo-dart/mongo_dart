part of mongo_dart;

class MongoMessageHandler {
  final _log = new Logger('MongoMessageTransformer');
  final converter = new PacketConverter();
//  final debugData = new File('debug_data1.bin').openSync(mode: FileMode.WRITE);
  
  void handleData(List<int> data, EventSink<MongoReplyMessage> sink) {
    //    debugData.writeFromSync(data);
    //    debugData.flushSync();
    //_log.fine('handleData length=${data.length} $data');
    converter.addPacket(data);
    while (!converter.messages.isEmpty) {
      var buffer = new BsonBinary.from(converter.messages.removeFirst());
      MongoReplyMessage reply = new MongoReplyMessage();
      reply.deserialize(buffer);
      _log.fine(reply.toString());
      sink.add(reply);
    }
  }
  
  void handleDone(EventSink<MongoReplyMessage> sink) {
    if (!converter.isClear) {
      _log.warning('Invalid state of PacketConverter in handleDone: $converter');
    }
    sink.close();
  }
  
  StreamTransformer<List<int>, MongoReplyMessage> get transformer => new StreamTransformer<List<int>, MongoReplyMessage>.fromHandlers(
      handleData: handleData,handleDone: handleDone);
}
