library packet_converter_test;

import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  group('Packet converter basics', () {
    test('PacketConverter creation', () {
      var converter = PacketConverter();
      expect(converter, isNotNull);
    });
    test('bytesAvailable', () {
      var converter = PacketConverter();
      converter.packets.addAll([
        [1, 2, 3],
        [4, 5, 6, 7]
      ]);
      expect(converter.bytesAvailable(), 7);
      converter.readPos = 2;
      expect(converter.bytesAvailable(), 5);
    });
    test('readIntoBuffer 1', () {
      var converter = PacketConverter();
      var buffer = List<int>.filled(7, 0);
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
      var converter = PacketConverter();
      var buffer = List<int>.filled(5, 0);
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
      var converter = PacketConverter();
      var buffer = List<int>.filled(3, 0);
      converter.packets.addAll([
        [1, 2, 3],
        [4, 5, 6, 7]
      ]);
      converter.readPos = 2;
      converter.readIntoBuffer(buffer, 0);
      expect(buffer, [3, 4, 5]);
      expect(converter.readPos, 2);
      expect(converter.bytesAvailable(), 2);
      buffer = List<int>.filled(2, 0);
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
      var converter = PacketConverter();
      converter.addPacket(packet);
      expect(converter.messages.length, 1);
      expect(converter.messages.first, packet);
    });

    test('Length part splitted', () {
      var converter = PacketConverter();
      converter.addPacket([7, 0, 0]);
      converter.addPacket([0, 1, 2, 3]);
      expect(converter.messages.length, 1);
      expect(converter.messages.first, [7, 0, 0, 0, 1, 2, 3]);
    });
    test('Packets not full for message', () {
      var converter = PacketConverter();
      converter.addPacket([7, 0, 0]);
      converter.addPacket([0, 1, 2]);
      expect(converter.messages, isEmpty);
    });
    test('Full message in one packet and some more', () {
      var packet = [7, 0, 0, 0, 1, 2, 3, 4, 5];
      var converter = PacketConverter();
      converter.addPacket(packet);
      expect(converter.messages.length, 1);
      expect(converter.messages.first, [7, 0, 0, 0, 1, 2, 3]);
      expect(converter.packets.length, 1);
      expect(converter.bytesAvailable(), 2);
    });
    test('Many message in one packet', () {
      var packet = [7, 0, 0, 0, 0, 1, 2, 7, 0, 0, 0, 0, 1, 2];
      for (var i = 0; i < 8000; i++) {
        packet.add(7);
        packet.add(0);
        packet.add(0);
        packet.add(0);
        packet.add(0);
        packet.add(1);
        packet.add(2);
      }

      var converter = PacketConverter();
      converter.addPacket(packet);
      expect(converter.messages.length, 8002);
      expect(converter.messages.first, [7, 0, 0, 0, 0, 1, 2]);
      expect(converter.packets.length, 0);
      expect(converter.bytesAvailable(), 0);
    });
  });
}
