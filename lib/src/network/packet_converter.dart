part of mongo_dart;

class PacketConverter {
  final packets = ListQueue<List<int>>();
  final messages = ListQueue<List<int>>();
  final MAX_DOC_SIZE = 32 * 1024 * 1024;
  bool headerMode = true;
  int bytesToRead = 4;
  List<int>? buffer;
  int readPos = 0;
  List<int>? messageBuffer;
  int messagesConverted = 0;
  final lengthBuffer = BsonBinary(4);

  void addPacket(List<int> packet) {
    packets.addLast(packet);
    handleHeaderAndBody();
  }

  void handleHeaderAndBody() {
    var hasMoreData = true;

    while (hasMoreData) {
      hasMoreData = false;
      if (headerMode) {
        if (bytesAvailable() >= 4) {
          handleHeader();
        }
      }
      if (!headerMode) {
        if (messageBuffer == null) {
          throw MongoDartError('Message buffer not yet initialized');
        }
        if (bytesAvailable() >= messageBuffer!.length - 4) {
          handleBody();
          if (bytesAvailable() >= 4) {
            hasMoreData = true;
          }
        }
      }
    }
  }

  void handleHeader() {
    headerMode = false;
    lengthBuffer.rewind();
    readIntoBuffer(lengthBuffer.byteList, 0);
    var len = lengthBuffer.readInt32();
    if (len > MAX_DOC_SIZE) {
      throw MongoDartError('Message length $len over maximum document size');
    }
    messageBuffer = List<int>.filled(len, 0);
  }

  void handleBody() {
    headerMode = true;
    if (messageBuffer == null) {
      throw MongoDartError('Message buffer not yet initialized');
    }
    messageBuffer!.setRange(0, 4, lengthBuffer.byteList);
    readIntoBuffer(messageBuffer!, 4);
    messagesConverted++;
    messages.addLast(messageBuffer!);
  }

  /// Length of all packets with current read position on first packet subtracted
  int bytesAvailable() =>
      packets.fold(-readPos, (value, element) => value + element.length);

  void readIntoBuffer(List<int> buffer, int pos) {
    if (buffer.length - pos > bytesAvailable()) {
//      print('$this $buffer $pos');
      throw MongoDartError('Bad state. Read buffer too big');
    }
    var writePos = pos;
    while (writePos < buffer.length) {
      writePos += _readPacketIntoBuffer(buffer, writePos);
    }
    if (writePos < buffer.length) {
      throw MongoDartError('Bad state. Buffer was not written fully');
    }
  }

  int _readPacketIntoBuffer(List<int> buffer, int pos) {
    var bytesRead = min(buffer.length - pos, packets.first.length - readPos);
    buffer.setRange(pos, pos + bytesRead, packets.first, readPos);
    if (readPos + bytesRead == packets.first.length) {
      readPos = 0;
      packets.removeFirst();
    } else {
      readPos += bytesRead;
    }
    return bytesRead;
  }

  @override
  String toString() =>
      'PacketConverter(readPos: $readPos, headerMode: $headerMode, packets: $packets)';

  bool get isClear => packets.isEmpty && messages.isEmpty && headerMode;
}
