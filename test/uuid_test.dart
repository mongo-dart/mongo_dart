@Timeout(Duration(seconds: 100))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart' hide UuidValue;

const dbName = 'test';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

late Db db;
Uuid uuid = Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  var name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

void main() async {
  Future initializeDatabase() async {
    db = Db(DefaultUri);
    await db.open();
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  group('Commands', () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Uuid:', () {
      test('read Uuid', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var uuid = Uuid().v4obj();
        await collection.insertOne({'uuid': uuid, 'null': null});

        var values = await collection.find(where.eq('uuid', uuid)).toList();

        expect(values.length, 1);
        expect(values.first['uuid'], uuid);
        expect(values.first['null'], isNull);
      });

      test('update Uuid', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var uuid = Uuid().v4obj();
        await collection.insertOne({'uuid': uuid, 'null': null});

        await collection.updateOne(
            where.eq('null', null), ModifierBuilder().set('newField', 12));

        var values = await collection.find().toList();

        expect(values.length, 1);
        expect(values.first['uuid'], uuid);
        expect(values.first['null'], isNull);
        expect(values.first['newField'], 12);
      });

      test('replace Uuid', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);
        var uuid = Uuid().v4obj();
        await collection.insertOne({'uuid': uuid, 'null': null});

        var uuidNew = Uuid().v4obj();
        await collection.replaceOne(
            where.eq('notNull', 0), {'uuid': uuidNew, 'notNull': 0},
            upsert: true);

        var values = await collection.find().toList();

        expect(values.length, 2);
        expect(values.first['uuid'], uuid);
        expect(values.first['null'], isNull);
        expect(values.last['uuid'], uuidNew);
      });

      test('delete Uuid', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);
        var uuid = Uuid().v4obj();
        await collection.insertOne({'uuid': uuid, 'null': null});

        await collection.deleteOne(where.eq('uuid', uuid));

        var values = await collection.find().toList();

        expect(values.isEmpty, isTrue);
      });
    });
  });

  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
