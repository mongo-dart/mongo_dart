library packet_converter_test;

import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

main() {
  group('Packet converter basics', () {
    test('PacketConverter creation', () {
      var converter = new PacketConverter();
      expect(converter, isNotNull);
    });
    test('bytesAvailable', () {
      var converter = new PacketConverter();
      converter.packets.addAll([
        [1, 2, 3],
        [4, 5, 6, 7]
      ]);
      expect(converter.bytesAvailable(), 7);
      converter.readPos = 2;
      expect(converter.bytesAvailable(), 5);
    });
    test('readIntoBuffer 1', () {
      var converter = new PacketConverter();
      var buffer = new List<int>(7);
      converter.packets.addAll([
        [1, 2, 3],
        [4, 5, 6, 7]
      ]);
      converter.readIntoBuffer(buffer, 0);
      expect(buffer, [1, 2, 3, 4, 5, 6, 7]);
      expect(converter.readPos, 0);
      expect(converter.packets, isEmpty);
    });
    test('readIntoBuffer 2', () {
      var converter = new PacketConverter();
      var buffer = new List<int>(5);
      converter.packets.addAll([
        [1, 2, 3],
        [4, 5, 6, 7]
      ]);
      converter.readPos = 2;
      converter.readIntoBuffer(buffer, 0);
      expect(buffer, [3, 4, 5, 6, 7]);
      expect(converter.readPos, 0);
      expect(converter.packets, isEmpty);
    });
    test('readIntoBuffer 3', () {
      var converter = new PacketConverter();
      var buffer = new List<int>(3);
      converter.packets.addAll([
        [1, 2, 3],
        [4, 5, 6, 7]
      ]);
      converter.readPos = 2;
      converter.readIntoBuffer(buffer, 0);
      expect(buffer, [3, 4, 5]);
      expect(converter.readPos, 2);
      expect(converter.bytesAvailable(), 2);
      buffer = new List<int>(2);
      converter.readIntoBuffer(buffer, 0);
      expect(buffer, [6, 7]);
      expect(converter.packets, isEmpty);
      expect(converter.readPos, 0);
    });
  });
  group('PacketConverter messages tests', () {
    test('Full message in one packet', () {
      // Length of 7 in first four bytes and 3 elements.
      // Full message in one packet
      var packet = [7, 0, 0, 0, 1, 2, 3];
      var converter = new PacketConverter();
      converter.addPacket(packet);
      expect(converter.messages.length, 1);
      expect(converter.messages.first, packet);
    });

    test('Length part splitted', () {
      var converter = new PacketConverter();
      converter.addPacket([7, 0, 0]);
      converter.addPacket([0, 1, 2, 3]);
      expect(converter.messages.length, 1);
      expect(converter.messages.first, [7, 0, 0, 0, 1, 2, 3]);
    });
    test('Packets not full for message', () {
      var converter = new PacketConverter();
      converter.addPacket([7, 0, 0]);
      converter.addPacket([0, 1, 2]);
      expect(converter.messages, isEmpty);
    });
    test('Full message in one packet and some more', () {
      var packet = [7, 0, 0, 0, 1, 2, 3, 4, 5];
      var converter = new PacketConverter();
      converter.addPacket(packet);
      expect(converter.messages.length, 1);
      expect(converter.messages.first, [7, 0, 0, 0, 1, 2, 3]);
      expect(converter.packets.length, 1);
      expect(converter.bytesAvailable(), 2);
    });
  });
}
