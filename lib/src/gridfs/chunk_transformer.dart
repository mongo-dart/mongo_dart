part of mongo_dart;

class ChunkTransformer extends StreamEventTransformer<List<int>, List<int>> {
  int chunkSize; 
  List<int> _carry;

  ChunkTransformer([this.chunkSize = 1024 * 256]);

  void _handle(List<int> data, StreamSink<List<int>> sink, bool isClosing) {  // <== added sink.
      if (_carry != null) {
        data.addAll(_carry);
        _carry = null;
      }
      int startPos = 0;
      int pos = 0;
      while (pos + chunkSize < data.length) {        
        sink.add(data.getRange(pos,chunkSize));  // <== changed to sink.
        pos += chunkSize;
      }        
      if (data.length > pos) {
        _carry = data.getRange(pos, data.length - pos);  
        if (isClosing) {
          sink.add(_carry);  // <== changed to sink
        }
      }
    }

  void handleData(List<int> data, StreamSink<List<int>> sink) {
    _handle(data, sink, false);
  }

  void handleDone(StreamSink<List<int>> sink) {
    _handle([], sink, true);
    sink.close();
  }
}