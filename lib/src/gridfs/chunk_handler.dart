part of mongo_dart;

class ChunkHandler {
  int chunkSize;
  Uint8List chunkData;
  int chunkDataLoaded = 0;

  ChunkHandler([this.chunkSize = 1024 * 256])
      : chunkData = Uint8List(chunkSize);

  void _handle(List<int> data, EventSink<Uint8List> sink, bool isClosing) {
    if (isClosing) {
      if (chunkDataLoaded == 0) {
        return;
      }
      sink.add(chunkData.sublist(0, chunkDataLoaded));
      return;
    }
    if (chunkDataLoaded + data.length >= chunkSize) {
      var remainingData = data.length;
      var fillingBytes = chunkSize - chunkDataLoaded;
      var startIndex = 0;
      var endIndex = fillingBytes;
      while (fillingBytes > 0) {
        chunkData.setAll(chunkDataLoaded, data.sublist(startIndex, endIndex));
        if (chunkDataLoaded + fillingBytes < chunkSize) {
          chunkDataLoaded = fillingBytes;
          break;
        }
        sink.add(chunkData);
        chunkData = Uint8List(chunkSize);
        chunkDataLoaded = 0;
        startIndex = endIndex;
        remainingData -= fillingBytes;
        fillingBytes = remainingData > chunkSize ? chunkSize : remainingData;
        endIndex += fillingBytes;
      }
    } else {
      chunkData.setAll(chunkDataLoaded, data);
      chunkDataLoaded += data.length;
    }
  }

  void handleData(List<int> data, EventSink<Uint8List> sink) =>
      _handle(data, sink, false);

  void handleError(
      Object error, StackTrace stackTrace, EventSink<Uint8List> sink) {
    print(error);
    print(stackTrace);
    sink.addError(error);
  }

  void handleDone(EventSink<Uint8List> sink) {
    _handle([], sink, true);
    sink.close();
  }

  StreamTransformer<List<int>, Uint8List> get transformer =>
      StreamTransformer<List<int>, Uint8List>.fromHandlers(
          handleData: handleData, handleDone: handleDone);
}
