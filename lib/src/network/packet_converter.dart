part of mongo_dart;
class PacketConverter {
  final _log = new Logger('PacketConverter');
  final packets = new ListQueue<List<int>>();
  bool headerMode = true;
  int bytesToRead = 4;
  List<int> buffer;
  int readPos = 0;
  BsonBinary _messageBinary;

  addPacket(List<int> packet) {
    packets.addLast(packet);
  }
  /// Length of all packets with current read position on first packet subtracted
  int bytesAvailable() => packets.fold(- readPos,(value, element) => value + element.length) ;
  void readIntoBuffer(List<int> buffer, int pos) {
    if(buffer.length - pos > bytesAvailable()) {
      throw new MongoDartException('Bad state. Read buffer too big');
    }
    int writePos = pos;
    while (writePos < buffer.length) {
      writePos += _readPacketIntoBuffer(buffer, writePos);
    }
    if (writePos < buffer.length) {
      throw new MongoDartException('Bad state. Buffer was not written fully');
    }
  }
  int _readPacketIntoBuffer(List<int> buffer, int pos) {
    int bytesRead = min(buffer.length - pos,packets.first.length - readPos);
    buffer.setRange(pos,pos+bytesRead,packets.first,readPos);
    if (readPos + bytesRead == packets.first.length) {
      readPos = 0;
      packets.removeFirst();
    } else {
      readPos += bytesRead;
    }
    return bytesRead;
  }
  String toString() => 'PacketConverter(readPos: $readPos, packets: $packets)';
}
