part of mongo_dart;

class PacketConverter {
  final _log = new Logger('PacketConverter');
  final packets = new ListQueue<List<int>>();
  final messages = new ListQueue<List<int>>();
  final MAX_DOC_SIZE = 32 * 1024 * 1024;
  bool headerMode = true;
  int bytesToRead = 4;
  List<int> buffer;
  int readPos = 0;
  List<int> messageBuffer;
  int messagesConverted = 0;
  final lengthBuffer = new BsonBinary(4);

  addPacket(List<int> packet) {
    packets.addLast(packet);
    //print('addPacket to $this');
    if (headerMode) {
      handleHeader();
    } else {
      handleBody();
    }
  }

  handleHeader() {
    if (bytesAvailable() >= 4) {
      headerMode = false;
      lengthBuffer.rewind();
      readIntoBuffer(lengthBuffer.byteList, 0);
      int len = lengthBuffer.readInt32();
      if (len > MAX_DOC_SIZE) {
        throw new MongoDartError(
            'Message length $len over maximum document size');
      }
      messageBuffer = new List<int>(len);
      handleBody();
    }
  }

  handleBody() {
    if (bytesAvailable() >= messageBuffer.length - 4) {
      headerMode = true;
      messageBuffer.setRange(0, 4, lengthBuffer.byteList);
      readIntoBuffer(messageBuffer, 4);
      messagesConverted++;
      messages.addLast(messageBuffer);
      handleHeader();
    }
  }

  /// Length of all packets with current read position on first packet subtracted
  int bytesAvailable() =>
      packets.fold(-readPos, (value, element) => value + element.length);

  void readIntoBuffer(List<int> buffer, int pos) {
    if (buffer.length - pos > bytesAvailable()) {
//      print('$this $buffer $pos');
      throw new MongoDartError('Bad state. Read buffer too big');
    }
    int writePos = pos;
    while (writePos < buffer.length) {
      writePos += _readPacketIntoBuffer(buffer, writePos);
    }
    if (writePos < buffer.length) {
      throw new MongoDartError('Bad state. Buffer was not written fully');
    }
  }

  int _readPacketIntoBuffer(List<int> buffer, int pos) {
    int bytesRead = min(buffer.length - pos, packets.first.length - readPos);
    buffer.setRange(pos, pos + bytesRead, packets.first, readPos);
    if (readPos + bytesRead == packets.first.length) {
      readPos = 0;
      packets.removeFirst();
    } else {
      readPos += bytesRead;
    }
    return bytesRead;
  }

  String toString() =>
      'PacketConverter(readPos: $readPos, headerMode: $headerMode, packets: $packets)';

  bool get isClear => this.packets.isEmpty && messages.isEmpty && headerMode;
}
