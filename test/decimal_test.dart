@Timeout(Duration(seconds: 100))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const dbName = 'test';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

var throwsMongoDartError = throwsA((e) => e is MongoDartError);

Db db;
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

  Future insertManyDocuments(
      DbCollection collection, int numberOfRecords) async {
    await collection.remove(<String, dynamic>{});
    var toInsert = <Map<String, dynamic>>[];
    for (var n = 0; n < numberOfRecords; n++) {
      toInsert.add({'a': Rational.fromInt(n)});
    }

    await collection.insertAll(toInsert);
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

    group('Decimal:', () {
      test('read Decimal', () async {
        var collectionName = getRandomCollectionName();
        ;
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 10000);

        var values = await collection.find(<String, dynamic>{}).toList();

        expect(values.length, 10000);

        expect(values.last['a'], Rational.fromInt(9999));

        var ra = Rational.parse('999999999999999999999999999999');
        for (var idx = 0; idx < 10; idx++) {
          var value = values[idx];
          var update = (value['a'] as Rational) + ra;
          //print(update);
          await collection.update(<String, dynamic>{
            '_id': value['_id']
          }, <String, dynamic>{
            r'$set': {'r': update}
          });
        }
      });
      test('update Decimal', () async {
        var collectionName = getRandomCollectionName();
        ;
        var collection = db.collection(collectionName);

        await collection
            .insert(<String, dynamic>{'value': Rational.fromInt(3), 'qty': 4});

        await collection.update(<String, dynamic>{}, <String, dynamic>{
          r'$mul': {'value': Rational.fromInt(5), 'qty': 5}
        });

        var values = await collection.find().toList();

        expect(values.length, 1);

        expect(values.first['value'], Rational.fromInt(15));
        expect(values.first['qty'], 20);
      });
      test('update Decimal with Modifier', () async {
        var collectionName = getRandomCollectionName();
        ;
        var collection = db.collection(collectionName);

        await collection.insertOne(
            <String, dynamic>{'value': Rational.fromInt(3), 'qty': 4});

        var mody = ModifierBuilder()
          ..inc('value', Rational.fromInt(2))
          ..inc('qty', 3);

        await collection.update(<String, dynamic>{}, mody.map);

        var values = await collection.find(<String, dynamic>{}).toList();

        expect(values.length, 1);

        expect(values.last['value'], Rational.fromInt(5));
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
