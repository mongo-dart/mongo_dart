@Timeout(Duration(seconds: 100))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

const dbName = 'test';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

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
    db = Db(defaultUri);
    await db.open();
  }

  Future insertManyDocuments(
      DbCollection collection, int numberOfRecords) async {
    await collection.remove(<String, dynamic>{});
    var toInsert = <Map<String, dynamic>>[];
    for (var n = 0; n < numberOfRecords; n++) {
      toInsert.add({'a': Decimal.fromInt(n)});
    }

    await collection.insertAll(toInsert);
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  group('Commands', () {
    var cannotRunTests = false;

    setUp(() async {
      await initializeDatabase();
      if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Decimal:', () {
      test('read Decimal', () async {
        if (cannotRunTests) {
          return;
        }
        var collectionName = getRandomCollectionName();

        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 10000);

        var values = await collection.find(<String, dynamic>{}).toList();

        expect(values.length, 10000);

        expect(values.last['a'], Decimal.fromInt(9999));

        var ra = Decimal.parse('999999999999999999999999999999');
        for (var idx = 0; idx < 10; idx++) {
          var value = values[idx];
          var update = (value['a'] as Decimal) + ra;
          //print(update);
          await collection.update(<String, dynamic>{
            '_id': value['_id']
          }, <String, dynamic>{
            r'$set': {'r': update}
          });
        }
      });
      test('update Decimal', () async {
        if (cannotRunTests) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection
            .insert(<String, dynamic>{'value': Decimal.fromInt(3), 'qty': 4});

        await collection.update(<String, dynamic>{}, <String, dynamic>{
          r'$mul': {'value': Decimal.fromInt(5), 'qty': 5}
        });

        var values = await collection.find().toList();

        expect(values.length, 1);
        expect(values.first['value'], Decimal.fromInt(15));
        expect(values.first['qty'], 20);

        await collection.update(where,
            ModifierBuilder().mul('value', Decimal.fromInt(5)).mul('qty', 2));
        values = await collection.find().toList();

        expect(values.length, 1);
        expect(values.first['value'], Decimal.fromInt(75));
        expect(values.first['qty'], 40);
      });
      test('update Decimal with Modifier', () async {
        if (cannotRunTests) {
          return;
        }
        var collectionName = getRandomCollectionName();

        var collection = db.collection(collectionName);

        await collection.insertOne(
            <String, dynamic>{'value': Decimal.fromInt(3), 'qty': 4});

        var mody = ModifierBuilder()
          ..inc('value', Decimal.fromInt(2))
          ..inc('qty', 3);

        await collection.update(<String, dynamic>{}, mody.map);

        var values = await collection.find(<String, dynamic>{}).toList();

        expect(values.length, 1);

        expect(values.last['value'], Decimal.fromInt(5));
        expect(values.last['qty'], 7);
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
