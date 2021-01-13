import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/bulk/ordered_bulk.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/bulk/unordered_bulk.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_request.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_request.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'utils/insert_data.dart';

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

  Future cleanupDatabase() async {
    await db.close();
  }

  group('Bulk Operations', () {
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

    group('Bulk insert', () {
      test('Ordered Bulk', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = OrderedBulk(collection);
        bulk.insertOne({'_id': 2, 'name': 'Stephen', 'age': 54});
        bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);

      test('Ordered Bulk - extra limit', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = OrderedBulk(collection);

        var docs = <Map<String, Object>>[];
        for (var idx = 0; idx < 220000; idx++) {
          docs.add(<String, Object>{'_id': idx, 'value': idx});
        }
        bulk.insertOne({'_id': 120000, 'name': 'Stephen', 'age': 54});
        bulk.insertMany(docs);

        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.writeErrorsNumber, 1);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 120001);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);

      test('Unordered Bulk', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = UnorderedBulk(collection);

        var docs = <Map<String, Object>>[];
        for (var idx = 0; idx < 220000; idx++) {
          docs.add(<String, Object>{'_id': idx, 'value': idx});
        }
        bulk.insertOne({'_id': 2, 'name': 'Stephen', 'age': 54});
        bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.isSuccess, isTrue);
        expect(ret.isPartialSuccess, isFalse);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.writeErrorsNumber, 0);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);
      test('Unordered Bulk - extra limit', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = UnorderedBulk(collection);

        var docs = <Map<String, Object>>[];
        for (var idx = 0; idx < 220000; idx++) {
          docs.add(<String, Object>{'_id': idx, 'value': idx});
        }
        bulk.insertOne({'_id': 2, 'name': 'Stephen', 'age': 54});
        bulk.insertMany(docs);
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.writeErrorsNumber, 2);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 220000);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);
    });

    group('Bulk delete', () {
      test('Unordered Bulk', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var retOrders = await insertOrders(collection);
        expect(retOrders.ok, 1.0);
        expect(retOrders.isSuccess, isTrue);

        var bulk = UnorderedBulk(collection, writeConcern: WriteConcern(w: 1));
        bulk.deleteMany(DeleteManyRequest({'status': 'D'}));

        bulk.deleteOne(DeleteOneRequest(
            {'cust_num': 99999, 'item': 'abc123', 'status': 'A'}));

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.delete);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 14);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);
    });

    group('Mixed functions', () {
      test('Ordered Bulk - Insert and delete one', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = OrderedBulk(collection);
        bulk.insertOne({'_id': 2, 'name': 'Stephen', 'age': 54});
        bulk.deleteOne(DeleteOneRequest({'_id': 2}));
        bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
        bulk.deleteOne(DeleteOneRequest({'_id': 4}));
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 2);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');

        var findResult = await collection.find().toList();
        expect(findResult.length, 3);
        expect(findResult.first['name'], 'John');
        expect(findResult.last['name'], 'Mandy');
      }, skip: cannotRunTests);

      test(
          'Ordered Bulk - Insert, delete one and delete many '
          'with collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.bulkWrite([
          {
            bulkInsertOne: {
              bulkDocument: {'_id': 2, 'name': 'Stephen', 'age': 54}
            }
          },
          {
            bulkDeleteOne: {
              bulkFilter: {'_id': 2}
            }
          },
          {
            bulkInsertMany: {
              bulkDocuments: [
                {'_id': 3, 'name': 'John', 'age': 32},
                {'_id': 4, 'name': 'Mira', 'age': 27},
                {'_id': 7, 'name': 'Luis', 'age': 42}
              ]
            }
          },
          {
            bulkDeleteMany: {
              bulkFilter: {
                'age': {r'$gt': 28}
              }
            }
          },
          {
            bulkInsertOne: {
              bulkDocument: {'_id': 5, 'name': 'Mandy', 'age': 21}
            }
          }
        ]);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 3);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.first['name'], 'Mira');
        expect(findResult.last['name'], 'Mandy');
      }, skip: cannotRunTests);

      test('Ordered Bulk - Insert, delete one and delete many', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = OrderedBulk(collection);
        bulk.insertOne({'_id': 2, 'name': 'Stephen', 'age': 54});
        bulk.deleteOne(DeleteOneRequest({'_id': 2}));
        bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
        bulk.deleteMany(DeleteManyRequest({
          'age': {r'$gt': 28}
        }));
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument();

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 3);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.first['name'], 'Mira');
        expect(findResult.last['name'], 'Mandy');
      }, skip: cannotRunTests);
    });
  });
  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
