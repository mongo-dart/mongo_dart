@Timeout(Duration(seconds: 100))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const dbName = 'test';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

late MongoClient client;
late MongoDatabase db;
Uuid uuid = Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  var name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

void main() async {
  Future initializeDatabase() async {
    var client = MongoClient(defaultUri);
    await client.connect();
    db = client.db();
  }

  Future cleanupDatabase() async {
    await client.close();
  }

  group('Commands', () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      await cleanupDatabase();
    });
    tearDownAll(() async {
      await client.connect();
      db = client.db();
      await Future.forEach(usedCollectionNames,
          (String collectionName) => db.collection(collectionName).drop());
      await client.close();
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

        var values = await collection.find({}).toList();

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

        var values = await collection.find({}).toList();

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

        var values = await collection.find({}).toList();

        expect(values.isEmpty, isTrue);
      });
    });
  });
}
