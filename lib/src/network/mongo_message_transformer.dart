part of mongo_dart;
class MongoMessageTransformer extends StreamEventTransformer<List<int>, MongoReplyMessage>{
  final _log = new Logger('MongoMessageTransformer');
  final packets = new ListQueue<List<int>>();
  bool headerMode = true;
  int bytesToRead = 4;
  List<int> buffer;
  int readPos = 0;
  BsonBinary _messageBinary;
void handleData(List<int> data, EventSink<List<int>> sink) {
    _log.fine('handleData length=${data.length} $data');
    packets.addLast(data);
    if (headerMode) {
      BsonBinary binary = new BsonBinary.from(data);
      int messageLength = binary.readInt32();
      _log.fine('message length = $messageLength');
      // Message length limit from https://jira.mongodb.org/browse/SERVER-5849
      if (messageLength > 48000000) {
        throw new MongoDartError('Message len is too large: $messageLength');
      }
      _messageBinary = new BsonBinary(messageLength);
      _messageBinary.byteList.setRange(0, 4 , data);
      chunkTransformer.chunkSize = messageLength - 4;
      headerMode = false;
    } else {
      chunkTransformer.chunkSize = 4;
      _log.fine('carry is ${chunkTransformer.carry}');
      headerMode = true;
      _messageBinary.byteList.setRange(4, _messageBinary.byteList.length , data);
      MongoReplyMessage reply = new MongoReplyMessage();
      reply.deserialize(_messageBinary);
      _log.fine(reply.toString());
      sink.add(reply);
    }
  }
  _addDataToBuffer(List<int> data) {
    if (buffer == null) {
      buffer = data;
    } else {
      var tmpBuffer = new List<int>(buffer.length-readPos+data.length);
      tmpBuffer.setRange(0,buffer.length,buffer, readPos-1);
      tmpBuffer.setRange(buffer.length,tmpBuffer.length,data);
      buffer = tmpBuffer;
    }
    readPos = 0;
  }

  void handleDone(EventSink<List<int>> sink) {
    if (!headerMode) {
      _log.warning('Invalid state in handleDone. headerMode=fase');
    }
    sink.close();
  }
  
}
