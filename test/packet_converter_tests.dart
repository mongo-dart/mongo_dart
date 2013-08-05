library packet_converter_test;
import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:mongo_dart/mongo_dart.dart';

main() {
  group('Packet converter basics',() {
    test('PacketConverter creation',(){
      var converter = new PacketConverter();
      expect(converter, isNotNull);
    });
    test('bytesAvailable',(){
      var converter = new PacketConverter();
      converter.addPacket([1,2,3]);
      converter.addPacket([4,5,6,7]);
      expect(converter.bytesAvailable(), 7);
      converter.readPos = 2;
      expect(converter.bytesAvailable(), 5);
    });
    test('readIntoBuffer 1',(){
      var converter = new PacketConverter();
      var buffer = new List<int>(7);
      converter.addPacket([1,2,3]);
      converter.addPacket([4,5,6,7]);
      converter.readIntoBuffer(buffer,0);
      expect(buffer,[1,2,3,4,5,6,7]);
      expect(converter.readPos,0);
      expect(converter.packets,isEmpty);
    });
    test('readIntoBuffer 2',(){
      var converter = new PacketConverter();
      var buffer = new List<int>(5);
      converter.addPacket([1,2,3]);
      converter.addPacket([4,5,6,7]);
      converter.readPos = 2;
      converter.readIntoBuffer(buffer,0);
      expect(buffer,[3,4,5,6,7]);
      expect(converter.readPos,0);
      expect(converter.packets,isEmpty);
    });
    test('readIntoBuffer 3',(){
      var converter = new PacketConverter();
      var buffer = new List<int>(3);
      converter.addPacket([1,2,3]);
      converter.addPacket([4,5,6,7]);
      converter.readPos = 2;
      converter.readIntoBuffer(buffer,0);
      expect(buffer,[3,4,5]);
      expect(converter.readPos,2);
      expect(converter.bytesAvailable(),2);
      buffer = new List<int>(2);
      converter.readIntoBuffer(buffer,0);
      expect(buffer,[6,7]);
      expect(converter.packets,isEmpty);
      expect(converter.readPos,0);
    });

  });
}