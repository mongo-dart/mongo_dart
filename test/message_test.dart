library message_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/message/additional/payload.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'dart:async';
import 'package:test/test.dart';

Future testCreatePayload0FromDocument() async {
  var data = <String, Object>{
    keyInsert: 'collectionName',
    keyDatabaseName: 'databaseName',
    keyWriteConcern: {'w': 'majority'}
  };
  var payload0 = Payload0(data);

  expect(payload0.byteLength, 89);
  var check = BsonBinary.fromHexString(
      '5900000002696e73657274000f000000636f6c6c656374696f6e4e616d6500022464620'
      '00d00000064617461626173654e616d6500037772697465436f6e6365726e0015000000'
      '027700090000006d616a6f72697479000000');
  var buffer = BsonBinary(payload0.byteLength);
  payload0.packValue(buffer);
  expect(buffer.offset, payload0.byteLength);
  expect(buffer.hexString, check.hexString);
}

Future testCreatePayload0FromBuffer() async {
  var data = <String, Object>{
    keyInsert: 'collectionName',
    keyDatabaseName: 'databaseName',
    keyWriteConcern: {'w': 'majority'}
  };
  var check = Payload0(data);
  var buffer = BsonBinary.fromHexString(
      '5900000002696e73657274000f000000636f6c6c656374696f6e4e616d6500022464620'
      '00d00000064617461626173654e616d6500037772697465436f6e6365726e0015000000'
      '027700090000006d616a6f72697479000000');
  buffer.offset = 0;
  var payload = Payload0.fromBuffer(buffer);

  expect(payload.byteLength, 89);

  expect(payload.byteLength, check.byteLength);
}

Future testCreatePayload1FromDocument() async {
  var data = <Map<String, Object>>[
    {keyId: 'Document#1', 'example': 1},
    {keyId: 'Document#2', 'example': 2},
    {keyId: 'Document#3', 'example': 3}
  ];
  var payload1 = Payload1('documents', data);

  expect(payload1.identifier.byteLength(), 10);
  expect(payload1.documentsByteLength, 114);
  expect(payload1.byteLength, 128);
  var check = BsonBinary.fromHexString(
      '80000000646f63756d656e74730026000000025f6964000b000000446f63756d656e74'
      '233100106578616d706c6500010000000026000000025f6964000b000000446f63756d'
      '656e74233200106578616d706c6500020000000026000000025f6964000b000000446f'
      '63756d656e74233300106578616d706c65000300000000');
  var buffer = BsonBinary(payload1.byteLength);
  payload1.packValue(buffer);
  expect(buffer.offset, payload1.byteLength);
  expect(buffer.hexString, check.hexString);
}

Future testCreatePayload1FromBuffer() async {
  var data = <Map<String, Object>>[
    {keyId: 'Document#1', 'example': 1},
    {keyId: 'Document#2', 'example': 2},
    {keyId: 'Document#3', 'example': 3}
  ];
  var check = Payload1('documents', data);
  var buffer = BsonBinary.fromHexString(
      '80000000646f63756d656e74730026000000025f6964000b000000446f63756d656e74'
      '233100106578616d706c6500010000000026000000025f6964000b000000446f63756d'
      '656e74233200106578616d706c6500020000000026000000025f6964000b000000446f'
      '63756d656e74233300106578616d706c65000300000000');
  buffer.offset = 0;
  var payload = Payload1.fromBuffer(buffer);

  expect(payload.identifier.byteLength(), 10);
  expect(payload.documentsByteLength, 114);
  expect(payload.byteLength, 128);

  expect(payload.byteLength, check.byteLength);
  expect(payload.identifier.toString(), check.identifier.toString());
  expect(payload.documentsByteLength, check.documentsByteLength);
}

Future testCreateSectionType0FromDocument() async {
  var data = <String, Object>{
    'insert': 'collectionName',
    keyDatabaseName: 'databaseName',
    'writeConcern': {'w': 'majority'}
  };
  var section0 = Section(MongoModernMessage.basePayloadType, data);
  var payload0 = Payload0(data);

  expect(section0.byteLength, 90);
  expect(payload0.byteLength, 89);
  var check = BsonBinary.fromHexString(
      '005900000002696e73657274000f000000636f6c6c656374696f6e4e616d6500022464'
      '62000d00000064617461626173654e616d6500037772697465436f6e6365726e001500'
      '0000027700090000006d616a6f72697479000000');
  var buffer = BsonBinary(section0.byteLength);
  section0.packValue(buffer);
  expect(buffer.offset, section0.byteLength);
  expect(buffer.hexString, check.hexString);
}

Future testCreateSectionType0FromBuffer() async {
  var data = <String, Object>{
    'insert': 'collectionName',
    keyDatabaseName: 'databaseName',
    'writeConcern': {'w': 'majority'}
  };
  var check = Section(MongoModernMessage.basePayloadType, data);
  var buffer = BsonBinary.fromHexString(
      '005900000002696e73657274000f000000636f6c6c656374696f6e4e616d6500022464'
      '62000d00000064617461626173654e616d6500037772697465436f6e6365726e001500'
      '0000027700090000006d616a6f72697479000000');
  buffer.offset = 0;
  var section = Section.fromBuffer(buffer);

  expect(section.byteLength, 90);

  expect(section.byteLength, check.byteLength);
}

Future testCreateSectionType1FromDocument() async {
  var data = <String, Object>{
    'documents': [
      {keyId: 'Document#1', 'example': 1},
      {keyId: 'Document#2', 'example': 2},
      {keyId: 'Document#3', 'example': 3}
    ]
  };
  var section = Section(MongoModernMessage.documentsPayloadType, data);

  expect((section.payload as Payload1).identifier.byteLength(), 10);
  expect((section.payload as Payload1).documentsByteLength, 114);
  expect(section.byteLength, 129);
  var check = BsonBinary.fromHexString(
      '0180000000646f63756d656e74730026000000025f6964000b000000446f63756d656e74'
      '233100106578616d706c6500010000000026000000025f6964000b000000446f63756d'
      '656e74233200106578616d706c6500020000000026000000025f6964000b000000446f'
      '63756d656e74233300106578616d706c65000300000000');
  var buffer = BsonBinary(section.byteLength);
  section.packValue(buffer);
  expect(buffer.offset, section.byteLength);
  expect(buffer.hexString, check.hexString);
}

Future testCreateSectionType1FromBuffer() async {
  var data = <String, Object>{
    'documents': [
      {keyId: 'Document#1', 'example': 1},
      {keyId: 'Document#2', 'example': 2},
      {keyId: 'Document#3', 'example': 3}
    ]
  };
  var check = Section(MongoModernMessage.documentsPayloadType, data);
  var buffer = BsonBinary.fromHexString(
      '0180000000646f63756d656e74730026000000025f6964000b000000446f63756d656e74'
      '233100106578616d706c6500010000000026000000025f6964000b000000446f63756d'
      '656e74233200106578616d706c6500020000000026000000025f6964000b000000446f'
      '63756d656e74233300106578616d706c65000300000000');
  buffer.offset = 0;
  var section = Section.fromBuffer(buffer);

  expect((section.payload as Payload1).identifier.byteLength(), 10);
  expect((section.payload as Payload1).documentsByteLength, 114);
  expect(section.byteLength, 129);

  expect(section.byteLength, check.byteLength);
  expect((section.payload as Payload1).identifier.toString(),
      (check.payload as Payload1).identifier.toString());
  expect((section.payload as Payload1).documentsByteLength,
      (check.payload as Payload1).documentsByteLength);
}

Future testCreateModernMessageFromDocument() async {
  var data = <String, Object>{
    keyInsert: 'collectionName',
    keyDatabaseName: 'databaseName',
    keyWriteConcern: {'w': 'majority'}
  };
  var documents = <Map<String, Object>>[];
  for (var idx = 1; idx <= 120; idx++) {
    documents.add(<String, Object>{'a': idx});
  }
  data[keyInsertArgument] = documents;

  var message = MongoModernMessage(data);
  expect(message.sections.length, 4);
  expect(message.opcode, MongoMessage.ModernMessage);
  var section0Number = 0;
  var section1Number = 0;
  var unknownSectionNumber = 0;
  for (var section in message.sections) {
    if (section.payloadType == MongoModernMessage.basePayloadType) {
      section0Number++;
    } else if (section.payloadType == MongoModernMessage.documentsPayloadType) {
      section1Number++;
    } else {
      unknownSectionNumber++;
    }
  }
  expect(section0Number, 1);
  expect(section1Number, 3);
  expect(unknownSectionNumber, 0);

  expect(message.messageLength, 1595);
  expect(message.serialize().byteLength(), 1600);
  expect(message.sections.first.byteLength, 90);
  expect(message.sections.last.byteLength, 255);
}

Future testCreateModernMessageFromBuffer() async {
  var data = <String, Object>{
    'insert': 'collectionName',
    keyDatabaseName: 'databaseName',
    'writeConcern': {'w': 'majority'}
  };
  var check = Section(MongoModernMessage.basePayloadType, data);
  var buffer = BsonBinary.fromHexString(
      '005900000002696e73657274000f000000636f6c6c656374696f6e4e616d6500022464'
      '62000d00000064617461626173654e616d6500037772697465436f6e6365726e001500'
      '0000027700090000006d616a6f72697479000000');
  buffer.offset = 0;
  var section = Section.fromBuffer(buffer);

  expect(section.byteLength, 90);

  expect(section.byteLength, check.byteLength);
}

void main() async {
  group('Main', () {
    group('Bson Payload0 Test', () {
      test('create Payload Type 0 from document',
          testCreatePayload0FromDocument);
      test('create Payload Type 0 from buffer', testCreatePayload0FromBuffer);
    });
    group('Bson Payload1 Test', () {
      test('create Payload Type 1 from document',
          testCreatePayload1FromDocument);
      test('create Payload Type 1 from buffer', testCreatePayload1FromBuffer);
    });
    group('Bson Section0 Test', () {
      test('create Section Type 0 from document',
          testCreateSectionType0FromDocument);
      test('create Section Type 0 from buffer',
          testCreateSectionType0FromBuffer);
    });
    group('Bson Section1 Test', () {
      test('create Section Type 1 from document',
          testCreateSectionType1FromDocument);
      test('create Section Type 1 from buffer',
          testCreateSectionType1FromBuffer);
    });
    group('Modern Message Test', () {
      test('create Moder Message from document',
          testCreateModernMessageFromDocument);
      test('create Moder Message from buffer',
          testCreateModernMessageFromBuffer);
    });
  });
}
