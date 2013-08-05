part of mongo_dart;

class ChunkTransformer extends StreamEventTransformer<List<int>, List<int>> {
  int chunkSize; 
  List<int> carry;

  ChunkTransformer([this.chunkSize = 1024 * 256]);

  void _handle(List<int> data, EventSink<List<int>> sink, bool isClosing) { 
      if (carry != null) {
        carry.addAll(data);
        data = carry;
        carry = null;
      }
      int startPos = 0;
      int pos = 0;
      while (pos + chunkSize < data.length) {        
        sink.add(data.sublist(pos,pos + chunkSize));  
        pos += chunkSize;
      }        
      if (data.length > pos) {
        carry = new List<int>();
        carry.addAll(data.sublist(pos));
        if (isClosing) {
          sink.add(carry);
        }
      }
    }

  void handleData(List<int> data, EventSink<List<int>> sink) {
    _handle(data, sink, false);
  }

  void handleDone(EventSink<List<int>> sink) {
    _handle([], sink, true);
    sink.close();
  }

}