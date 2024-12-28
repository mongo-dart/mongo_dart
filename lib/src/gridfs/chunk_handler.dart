part of '../../mongo_dart.dart';

class ChunkHandler {
  late Int32 chunkSize;
  late Uint8List chunkData;
  Int32 defaultChunkSize = Int32(1024 * 256);
  int chunkDataLoaded = 0;

  ChunkHandler([Int32? chunkSizeNumber]) {
    chunkSize = chunkSizeNumber ?? defaultChunkSize;
    chunkData = Uint8List(chunkSize.toInt());
  }

  void _handle(List<int> data, EventSink<Uint8List> sink, bool isClosing) {
    if (isClosing) {
      if (chunkDataLoaded == 0) {
        return;
      }
      sink.add(chunkData.sublist(0, chunkDataLoaded));
      return;
    }
    if (chunkDataLoaded + data.length >= chunkSize.toInt()) {
      var remainingData = data.length;
      var fillingBytes = chunkSize.toInt() - chunkDataLoaded;
      var startIndex = 0;
      var endIndex = fillingBytes;
      while (fillingBytes > 0) {
        chunkData.setAll(chunkDataLoaded, data.sublist(startIndex, endIndex));
        if (chunkDataLoaded + fillingBytes < chunkSize.toInt()) {
          chunkDataLoaded = fillingBytes;
          break;
        }
        sink.add(chunkData);
        chunkData = Uint8List(chunkSize.toInt());
        chunkDataLoaded = 0;
        startIndex = endIndex;
        remainingData -= fillingBytes;
        fillingBytes = remainingData > chunkSize.toInt()
            ? chunkSize.toInt()
            : remainingData;
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
