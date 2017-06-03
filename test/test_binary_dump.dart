library database_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';

main() {
  var raf = new File(r'c:\projects\mongo_dart\debug_data1.bin').openSync();
  int len = raf.lengthSync();
  var lenBuffer = new BsonBinary(4);
  int readPos = 0;
  int counter = 0;
  while (raf.positionSync() < len) {
    raf.readIntoSync(lenBuffer.byteList);
    lenBuffer.rewind();
    int messageLen = lenBuffer.readInt32();
    print('$messageLen');
    readPos += messageLen;
    counter++;
    print('counter: $counter readPos $readPos');
    raf.setPositionSync(readPos);
  }
}
