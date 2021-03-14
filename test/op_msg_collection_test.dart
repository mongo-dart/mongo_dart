import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/create_command/create_command.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/create_command/create_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/find_operation/find_options.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

final Matcher throwsMongoDartError = throwsA(TypeMatcher<MongoDartError>());

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
    var toInsert = <Map<String, dynamic>>[];
    for (var n = 0; n < numberOfRecords; n++) {
      toInsert.add({'a': n});
    }

    await collection.insertAll(toInsert);
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  group('Collections', () {
    var cannotRunTests = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('Simple create collection', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, collectionName).execute();
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      await insertManyDocuments(collection, 10000);
      var result = await collection.modernFind().toList();
      expect(result.length, 10000);
    }, skip: cannotRunTests);

    test('Simple create capped collection', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, collectionName,
              createOptions:
                  CreateOptions(capped: true, size: 5242880, max: 5000))
          .execute();
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      await insertManyDocuments(collection, 10000);
      var result = await collection.modernFind().toList();

      expect(result.length, 5000);
    }, skip: cannotRunTests);

    test('Simple create collection with schema', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, collectionName,
          createOptions: CreateOptions(validator: {
            r'$jsonSchema': {
              'bsonType': 'object',
              'required': ['phone'],
              'properties': {
                'phone': {
                  'bsonType': 'string',
                  'description': 'must be a string and is required'
                },
                'email': {
                  'bsonType': 'string',
                  'pattern': r'@mongodb\.com$',
                  'description':
                      'must be a string and match the regular expression pattern'
                },
                'status': {
                  'enum': ['Unknown', 'Incomplete'],
                  'description': 'can only be one of the enum values'
                }
              }
            }
          })).execute();
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      var writeResult = await collection.insertOne(
          {'name': 'Anand', 'phone': '451 3874643', 'status': 'Incomplete'},
          writeConcern: WriteConcern.MAJORITY);
      expect(writeResult.isSuccess, isTrue);

      writeResult = await collection.insertOne(
          {'name': 'Amanda', 'status': 'Updated'},
          writeConcern: WriteConcern.MAJORITY);
      expect(writeResult.isSuccess, isFalse);
      expect(writeResult.operationSucceeded, isTrue);
      expect(writeResult.hasWriteErrors, isTrue);
      expect(writeResult.writeError.code, 121);
    }, skip: cannotRunTests);

    test('Simple create collection with no collation', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, collectionName).execute();
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      await collection.insertOne({'_id': 1, 'category': 'café'});
      await collection.insertOne({'_id': 2, 'category': 'cafe'});
      await collection.insertOne({'_id': 3, 'category': 'cafE'});

      var result = await collection
          .modernFind(selector: SelectorBuilder()..sortBy('category'))
          .toList();

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      expect(result.length, 3);
      expect(result.first['category'], 'cafE');
      expect(result.last['category'], 'café');
    }, skip: cannotRunTests);

    test('Simple create collection with collation', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, collectionName,
              createOptions: CreateOptions(collation: CollationOptions('fr')))
          .execute();
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      await collection.insertOne({'_id': 1, 'category': 'café'});
      await collection.insertOne({'_id': 2, 'category': 'cafe'});
      await collection.insertOne({'_id': 3, 'category': 'cafE'});

      var result = await collection
          .modernFind(selector: SelectorBuilder()..sortBy('category'))
          .toList();

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      expect(result.length, 3);
      expect(result.first['category'], 'cafe');
      expect(result.last['category'], 'café');
    }, skip: cannotRunTests);

    test('Simple create collection with storage engine options', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, collectionName,
          createOptions: CreateOptions(storageEngine: {
            'wiredTiger': {
              'configString': 'log=(enabled),block_compressor=snappy'
            }
          })).execute();
      expect(resultMap[keyOk], 1.0);
    }, skip: cannotRunTests);
  });

  group('Views', () {
    var cannotRunTests = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('Simple create view', () async {
      var collectionName = 'abc';
      var viewName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, viewName,
          createOptions: CreateOptions(viewOn: collectionName, pipeline: [
            {
              r'$project': {
                'management': r'$feedback.management',
                'department': 1
              }
            }
          ])).execute();
      expect(resultMap[keyOk], 1.0);

      var collection = db.collection(collectionName);
      var view = db.collection(viewName);
      await collection.insertOne({
        '_id': 1,
        'empNumber': 'abc123',
        'feedback': {'management': 3, 'environment': 3},
        'department': 'A'
      });
      await collection.insertOne({
        '_id': 2,
        'empNumber': 'xyz987',
        'feedback': {'management': 2, 'environment': 3},
        'department': 'B'
      });
      await collection.insertOne({
        '_id': 3,
        'empNumber': 'ijk555',
        'feedback': {'management': 3, 'environment': 4},
        'department': 'A'
      });

      var result = await view.modernFind().toList();
      expect(result.first['department'], 'A');
      expect(result.first['management'], 3);
      expect(result[1]['department'], 'B');
      expect(result[1]['management'], 2);
    }, skip: cannotRunTests);

    test('Create view with aggregate sort', () async {
      var collectionName = 'abc';
      var viewName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, viewName,
          createOptions: CreateOptions(viewOn: collectionName, pipeline: [
            {
              r'$project': {
                'management': r'$feedback.management',
                'department': 1
              }
            },
            {r'$sortByCount': r'$department'}
          ])).execute();
      expect(resultMap[keyOk], 1.0);

      var collection = db.collection(collectionName);
      var view = db.collection(viewName);
      await collection.insertOne({
        '_id': 1,
        'empNumber': 'abc123',
        'feedback': {'management': 3, 'environment': 3},
        'department': 'A'
      });
      await collection.insertOne({
        '_id': 2,
        'empNumber': 'xyz987',
        'feedback': {'management': 2, 'environment': 3},
        'department': 'B'
      });
      await collection.insertOne({
        '_id': 3,
        'empNumber': 'ijk555',
        'feedback': {'management': 3, 'environment': 4},
        'department': 'A'
      });

      var result = await view.modernFind().toList();
      expect(result.first['_id'], 'A');
      expect(result.first['count'], 2);
      expect(result.last['_id'], 'B');
      expect(result.last['count'], 1);
    }, skip: cannotRunTests);
    test('Create view and aggregate later', () async {
      var collectionName = 'abc';
      var viewName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, viewName,
          createOptions: CreateOptions(viewOn: collectionName, pipeline: [
            {
              r'$project': {
                'management': r'$feedback.management',
                'department': 1
              }
            }
          ])).execute();
      expect(resultMap[keyOk], 1.0);

      var collection = db.collection(collectionName);
      var view = db.collection(viewName);
      await collection.insertOne({
        '_id': 1,
        'empNumber': 'abc123',
        'feedback': {'management': 3, 'environment': 3},
        'department': 'A'
      });
      await collection.insertOne({
        '_id': 2,
        'empNumber': 'xyz987',
        'feedback': {'management': 2, 'environment': 3},
        'department': 'B'
      });
      await collection.insertOne({
        '_id': 3,
        'empNumber': 'ijk555',
        'feedback': {'management': 3, 'environment': 4},
        'department': 'A'
      });

      var result = await view.aggregateToStream([
        {r'$sortByCount': r'$department'}
      ]).toList();
      expect(result.first['_id'], 'A');
      expect(result.first['count'], 2);
      expect(result.last['_id'], 'B');
      expect(result.last['count'], 1);
    }, skip: cannotRunTests);

    test('Create a view from multiple collections', () async {
      var collection1Name = 'orders.a';
      var collection2Name = 'inventory.a';
      var collection1 = db.collection(collection1Name);
      var collection2 = db.collection(collection2Name);

      await collection1.insertOne({
        '_id': 1,
        'item': 'abc',
        'price': Rational.parse('12.00'),
        'quantity': 2
      });
      await collection1.insertOne({
        '_id': 2,
        'item': 'jkl',
        'price': Rational.parse('20.00'),
        'quantity': 1
      });
      await collection1.insertOne({
        '_id': 3,
        'item': 'abc',
        'price': Rational.parse('10.95'),
        'quantity': 5
      });
      await collection1.insertOne({
        '_id': 4,
        'item': 'xyz',
        'price': Rational.parse('5.95'),
        'quantity': 5
      });
      await collection1.insertOne({
        '_id': 5,
        'item': 'xyz',
        'price': Rational.parse('5.95'),
        'quantity': 10
      });

      await collection2.insertOne(
          {'_id': 1, 'sku': 'abc', 'description': 'product 1', 'instock': 120});
      await collection2.insertOne(
          {'_id': 2, 'sku': 'def', 'description': 'product 2', 'instock': 80});
      await collection2.insertOne(
          {'_id': 3, 'sku': 'ijk', 'description': 'product 3', 'instock': 60});
      await collection2.insertOne(
          {'_id': 4, 'sku': 'jkl', 'description': 'product 4', 'instock': 70});
      await collection2.insertOne(
          {'_id': 5, 'sku': 'xyz', 'description': 'product 5', 'instock': 200});

      var viewName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, viewName,
          createOptions: CreateOptions(viewOn: collection1Name, pipeline: [
            {
              r'$lookup': {
                'from': collection2Name,
                'localField': 'item',
                'foreignField': 'sku',
                'as': 'inventory_docs'
              }
            },
            {
              r'$project': {'inventory_docs._id': 0, 'inventory_docs.sku': 0}
            }
          ])).execute();
      expect(resultMap[keyOk], 1.0);

      var view = db.collection(viewName);

      var result = await view.modernFind().toList();

      expect(result.length, 5);

      expect(result.first['item'], 'abc');
      expect(result.first['price'], Rational.fromInt(12));
      expect(result.first['quantity'], 2);
      expect(result.first['inventory_docs'].first['instock'], 120);

      expect(result[1]['item'], 'jkl');
      expect(result[1]['price'], Rational.parse('20.00'));
      expect(result[1]['quantity'], 1);
      expect(result[1]['inventory_docs'].first['instock'], 70);
    }, skip: cannotRunTests);

    test('Aggregation pipeline on a view from multiple collections', () async {
      var collection1Name = 'orders';
      var collection2Name = 'inventory';
      var collection1 = db.collection(collection1Name);
      var collection2 = db.collection(collection2Name);

      await collection1.insertOne({
        '_id': 1,
        'item': 'abc',
        'price': Rational.parse('12.00'),
        'quantity': 2
      });
      await collection1.insertOne({
        '_id': 2,
        'item': 'jkl',
        'price': Rational.parse('20.00'),
        'quantity': 1
      });
      await collection1.insertOne({
        '_id': 3,
        'item': 'abc',
        'price': Rational.parse('10.95'),
        'quantity': 5
      });
      await collection1.insertOne({
        '_id': 4,
        'item': 'xyz',
        'price': Rational.parse('5.95'),
        'quantity': 5
      });
      await collection1.insertOne({
        '_id': 5,
        'item': 'xyz',
        'price': Rational.parse('5.95'),
        'quantity': 10
      });
      await collection1.insertOne({
        '_id': 6,
        'item': 'abc',
        'price': Rational.parse('14.00'),
        'quantity': 4
      });

      await collection2.insertOne(
          {'_id': 1, 'sku': 'abc', 'description': 'product 1', 'instock': 120});
      await collection2.insertOne(
          {'_id': 2, 'sku': 'def', 'description': 'product 2', 'instock': 80});
      await collection2.insertOne(
          {'_id': 3, 'sku': 'ijk', 'description': 'product 3', 'instock': 60});
      await collection2.insertOne(
          {'_id': 4, 'sku': 'jkl', 'description': 'product 4', 'instock': 70});
      await collection2.insertOne(
          {'_id': 5, 'sku': 'xyz', 'description': 'product 5', 'instock': 200});

      var viewName = getRandomCollectionName();
      var resultMap = await CreateCommand(db, viewName,
          createOptions: CreateOptions(viewOn: collection1Name, pipeline: [
            {
              r'$lookup': {
                'from': 'inventory',
                'localField': 'item',
                'foreignField': 'sku',
                'as': 'inventory_docs'
              }
            },
            {
              r'$project': {'inventory_docs._id': 0, 'inventory_docs.sku': 0}
            }
          ])).execute();
      expect(resultMap[keyOk], 1.0);

      var view = db.collection(viewName);

      var result = await view.modernAggregate([
        {r'$sortByCount': r'$item'}
      ]).toList();

      expect(result.length, 3);

      expect(result.first['_id'], 'abc');
      expect(result.first['count'], 3);
      expect(result.last['_id'], 'jkl');
      expect(result.last['count'], 1);
    }, skip: cannotRunTests);

    test('Create view with default Collation', () async {
      var collectionName = 'places';
      usedCollectionNames.add(collectionName);

      var collection = db.collection(collectionName);

      await collection.insertOne({'_id': 2, 'category': 'café'});
      await collection.insertOne({'_id': 3, 'category': 'cafe'});
      await collection.insertOne({'_id': 1, 'category': 'cafE'});
      await collection.insertOne({'_id': 4, 'category': 'lait'});
      await collection.insertOne({'_id': 5, 'category': 'Bière'});

      var viewName = 'alpha';
      usedCollectionNames.add(viewName);

      //getRandomCollectionName();
      var resultMap = await CreateCommand(
        db,
        viewName,
        createOptions: CreateOptions(
            viewOn: collectionName,
            pipeline: [
              {
                r'$project': {'category': 1}
              }
            ],
            collation: CollationOptions('fr')),
      ).execute();
      expect(resultMap[keyOk], 1.0);

      var view = db.collection(viewName);

      var result = await view
          .modernFind(
            selector: SelectorBuilder().sortBy('category'),
          )
          .toList();
      expect(result[1]['category'], 'cafe');
      expect(result[3]['category'], 'café');
    }, skip: cannotRunTests);

    test('Create view with default Collation - strength 1', () async {
      var collectionName = 'places2';
      usedCollectionNames.add(collectionName);

      var collection = db.collection(collectionName);

      await collection.insertOne({'_id': 2, 'category': 'café'});
      await collection.insertOne({'_id': 3, 'category': 'cafe'});
      await collection.insertOne({'_id': 1, 'category': 'cafE'});
      await collection.insertOne({'_id': 4, 'category': 'lait'});
      await collection.insertOne({'_id': 5, 'category': 'Bière'});

      var viewName = 'alpha2';
      usedCollectionNames.add(viewName);

      //getRandomCollectionName();
      var resultMap = await CreateCommand(db, viewName,
          createOptions: CreateOptions(
            viewOn: collectionName,
            pipeline: [
              {
                r'$project': {'category': 1}
              }
            ],
            /* collation: CollationOptions('fr', strength: 1) */
          ),
          rawOptions: {
            'collation': {'locale': 'fr', 'strength': 1}
          }).execute();
      expect(resultMap[keyOk], 1.0);

      var view = db.collection(viewName);

      var countRet = await view.count({'category': 'cafe'});
      expect(countRet, 3);
    }, skip: cannotRunTests);

    test('Error overriding view default Collation', () async {
      var collectionName = 'places3';
      usedCollectionNames.add(collectionName);

      var collection = db.collection(collectionName);

      await collection.insertOne({'_id': 2, 'category': 'café'});
      await collection.insertOne({'_id': 3, 'category': 'cafe'});
      await collection.insertOne({'_id': 1, 'category': 'cafE'});
      await collection.insertOne({'_id': 4, 'category': 'lait'});
      await collection.insertOne({'_id': 5, 'category': 'Bière'});

      var viewName = 'alpha3';
      usedCollectionNames.add(viewName);

      //getRandomCollectionName();
      var resultMap = await CreateCommand(
        db,
        viewName,
        createOptions: CreateOptions(
            viewOn: collectionName,
            pipeline: [
              {
                r'$project': {'category': 1}
              }
            ],
            collation: CollationOptions('fr')),
      ).execute();
      expect(resultMap[keyOk], 1.0);

      var view = db.collection(viewName);

      try {
        await view
            .modernFind(
                selector: SelectorBuilder().sortBy('category'),
                findOptions:
                    FindOptions(collation: CollationOptions('fr', strength: 1)))
            .toList();
      } on MongoDartError catch (error) {
        expect(error.mongoCode, 167);
        expect(error.errorCode, '167');
      } catch (error) {
        expect('$error', 'Should not throw this error');
      }
    }, skip: cannotRunTests);
  });

  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
