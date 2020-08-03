import 'dart:async';

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
    var pos = 0;
    while (pos + chunkSize < data.length) {
      sink.add(data.sublist(pos, pos + chunkSize));
      pos += chunkSize;
    }
    if (data.length > pos) {
      carry = <int>[];
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
      StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: handleData, handleDone: handleDone);
}

StreamTransformer<List<int>, List<int>> chunkTransformer(int chunkSize) {
  var chunkHandler = ChunkHandler(chunkSize);
  return StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: chunkHandler.handleData, handleDone: chunkHandler.handleDone);
}

void main() {
  var data = [
    [1, 3, 5, 6, 7, 8, 9, 3, 4, 5, 6, 1, 7],
    [2, 3, 6, 1]
  ];
  var stream = Stream.fromIterable(data);
  stream.transform(ChunkHandler(4).transformer).listen(print);
}
