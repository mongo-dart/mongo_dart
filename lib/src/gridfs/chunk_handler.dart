part of mongo_dart;

class ChunkHandler {
  int chunkSize;
  List<int> carry;

  ChunkHandler([this.chunkSize = 1024 * 256]);

  void _handle(List<int> data, EventSink<List<int>> sink, bool isClosing) {
    if (carry != null) {
      carry.addAll(data);
      data = carry;
      carry = null;
    }
    int pos = 0;
    while (pos + chunkSize < data.length) {
      sink.add(data.sublist(pos, pos + chunkSize));
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

  void handleError(
      Object error, StackTrace stackTrace, EventSink<List<int>> sink) {
    print(error);
    print(stackTrace);
  }

  void handleDone(EventSink<List<int>> sink) {
    _handle([], sink, true);
    sink.close();
  }

  StreamTransformer<List<int>, List<int>> get transformer =>
      new StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: handleData, handleDone: handleDone);
}
