import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/find_and_modify_operation/find_and_modify_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/find_and_modify_operation/find_and_modify_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_statement.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_statement.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:rational/rational.dart';
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

  group('Write Operations', () {
    var cannotRunTests = false;
    var running4_4orGreater = false;
    var running4_2orGreater = false;

    var isReplicaSet = false;
    var isStandalone = false;
    var isSharded = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
      var serverFcv = db?.masterConnection?.serverCapabilities?.fcv ?? '0.0';
      if (serverFcv.compareTo('4.4') != -1) {
        running4_4orGreater = true;
      }
      if (serverFcv.compareTo('4.2') != -1) {
        running4_2orGreater = true;
      }
      isReplicaSet =
          db?.masterConnection?.serverCapabilities?.isReplicaSet ?? false;
      isStandalone =
          db?.masterConnection?.serverCapabilities?.isStandalone ?? false;
      isSharded =
          db?.masterConnection?.serverCapabilities?.isShardedCluster ?? false;
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Insert One', () {
      test('InsertOne', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret =
            await collection.insertOne({'_id': 3, 'name': 'John', 'age': 32});
        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 1);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        expect(ret.id, 3);
        expect(ret.document['name'], 'John');
      }, skip: cannotRunTests);

      test('InsertOne no Id', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertOne({'item': 'card', 'qty': 15});
        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 1);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        expect(ret.id.runtimeType, ObjectId);
        expect(ret.document['item'], 'card');
      }, skip: cannotRunTests);

      test('InsertOne duplicate id', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret =
            await collection.insertOne({'_id': 10, 'item': 'card', 'qty': 15});
        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        ret = await collection
            .insertOne({'_id': 10, 'item': 'packing peanuts', 'qty': 200});
        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.isSuccess, isFalse);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        expect(ret.id, 10);
        expect(ret.document['item'], 'packing peanuts');
      }, skip: cannotRunTests);

      test('InsertOne increase Write Concern', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        // The error is caused by the number of servers (as we have a testing)
        // environment with at most three replica set members).
        var ret = await collection.insertOne(
            {'item': 'envelopes', 'qty': 100, 'type': 'Self-Sealing'},
            writeConcern: WriteConcern(w: 4, wtimeout: 5000, j: true));
        if (isStandalone) {
          expect(ret.ok, 0.0);
          expect(ret.operationSucceeded, isFalse);
          expect(ret.hasWriteConcernError, isFalse);
          expect(ret.taskCompleted, isFalse);
          expect(ret.nInserted, 0);
          expect(ret.isSuspendedSuccess, isFalse);
          expect(ret.isFailure, isTrue);
        } else {
          expect(ret.ok, 1.0);
          expect(ret.operationSucceeded, isTrue);
          expect(ret.hasWriteConcernError, isTrue);
          expect(ret.taskCompleted, isTrue);
          expect(ret.nInserted, 1);
          expect(ret.isSuspendedSuccess, isTrue);
          expect(ret.isFailure, isFalse);
        }
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        expect(ret.id.runtimeType, ObjectId);
        expect(ret.document['item'], 'envelopes');
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isFalse);
        expect(ret.isSuspendedPartial, isFalse);
        expect(ret.isPartial, isFalse);
      }, skip: cannotRunTests);
    });

    group('Insert Many', () {
      test('InsertMany', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 3);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        expect(ret.ids.first, 3);
        expect(ret.documents.first['name'], 'John');
        expect(ret.ids.last, 7);
        expect(ret.documents.last['name'], 'Luis');
      }, skip: cannotRunTests);

      test('Too much documents', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        expect(
            () => insertManyDocuments(
                collection, MongoModernMessage.maxWriteBatchSize + 1),
            throwsMongoDartError);
      }, skip: cannotRunTests);
    });

    group('Delete One', () {
      test('DeleteOne - first', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation =
            DeleteOneOperation(collection, DeleteOneStatement({}));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.first['name'], 'Mira');
      }, skip: cannotRunTests);

      test('DeleteOne - selected', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation =
            DeleteOneOperation(collection, DeleteOneStatement({key_id: 7}));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.last['name'], 'Mira');
      }, skip: cannotRunTests);
      test('DeleteOne - orders', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertOrders(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation =
            DeleteOneOperation(collection, DeleteOneStatement({'status': 'D'}));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find({'status': 'D'}).toList();
        expect(findResult.length, 12);
        expect(findResult.first['item'], 'tst24');
      }, skip: cannotRunTests);

      test('DeleteOne - first - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteOne(<String, Object>{});
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.first['name'], 'Mira');
      }, skip: cannotRunTests);

      test('DeleteOne - selected - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteOne(<String, Object>{key_id: 7});

        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.last['name'], 'Mira');
      }, skip: cannotRunTests);

      test('DeleteOne - orders - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertOrders(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteOne(<String, Object>{'status': 'D'});
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find({'status': 'D'}).toList();
        expect(findResult.length, 12);
        expect(findResult.first['item'], 'tst24');
      }, skip: cannotRunTests);
    });

    group('Delete Many', () {
      test('DeleteMany - all', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation =
            DeleteManyOperation(collection, DeleteManyStatement({}));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 3);

        var findResult = await collection.find().toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - selected', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation =
            DeleteManyOperation(collection, DeleteManyStatement({key_id: 7}));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.last['name'], 'Mira');
      }, skip: cannotRunTests);

      test('DeleteMany - orders', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertOrders(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation = DeleteManyOperation(
            collection, DeleteManyStatement({'status': 'D'}));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 13);

        var findResult = await collection.find({'status': 'D'}).toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - all orders', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertOrders(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation = DeleteManyOperation(
            collection, DeleteManyStatement({}),
            deleteManyOptions: DeleteManyOptions(
                writeConcern: WriteConcern(w: 'majority', wtimeout: 5000)));
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 35);

        var findResult = await collection.find(<String, Object>{}).toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - collation', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertFrenchCafe(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var deleteOperation = DeleteManyOperation(
          collection,
          DeleteManyStatement({'category': 'cafe', 'status': 'a'},
              collation: CollationOptions('fr', strength: 1)),
        );
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 3);

        var findResult = await collection.find().toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - hint', () async {
        if (cannotRunTests || !running4_4orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertMembers(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.createIndex(keys: {'status': 1});
        await collection.createIndex(keys: {'points': 1});

        var deleteOperation = DeleteManyOperation(
          collection,
          DeleteManyStatement({
            'points': {r'$lte': 20},
            'status': 'P'
          }, hintDocument: {
            'status': 1
          }),
        );
        var res = await deleteOperation.executeDocument();
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 3);

        var findResult = await collection.find().toList();
        expect(findResult.length, 3);
      });

      test('DeleteMany - all - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteMany(<String, Object>{});
        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 3);

        var findResult = await collection.find().toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - selected - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42},
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteMany(<String, Object>{key_id: 7});

        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 2);
        expect(findResult.last['name'], 'Mira');
      }, skip: cannotRunTests);

      test('DeleteMany - orders - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertOrders(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteMany(<String, Object>{'status': 'D'});

        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 13);

        var findResult = await collection.find({'status': 'D'}).toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - all orders - collection helper ', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertOrders(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteMany(<String, Object>{},
            writeConcern: WriteConcern(w: 'majority', wtimeout: 5000));

        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 35);

        var findResult = await collection.find(<String, Object>{}).toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - collation - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertFrenchCafe(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.deleteMany(
            <String, Object>{'category': 'cafe', 'status': 'a'},
            collation: CollationOptions('fr', strength: 1));

        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 3);

        var findResult = await collection.find().toList();
        expect(findResult.length, 0);
      }, skip: cannotRunTests);

      test('DeleteMany - hint - collection helper', () async {
        if (cannotRunTests || !running4_4orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertMembers(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.createIndex(keys: {'status': 1});
        await collection.createIndex(keys: {'points': 1});

        var res = await collection.deleteMany(<String, Object>{
          'points': {r'$lte': 20},
          'status': 'P'
        }, hintDocument: {
          'status': 1
        });

        expect(res.hasWriteErrors, isFalse);
        expect(res.hasWriteConcernError, isFalse);
        expect(res.nInserted, 0);
        expect(res.operationSucceeded, isTrue);
        expect(res.writeCommandType, WriteCommandType.delete);
        expect(res.nUpserted, 0);
        expect(res.nModified, 0);
        expect(res.nMatched, 0);
        expect(res.nRemoved, 3);

        var findResult = await collection.find().toList();
        expect(findResult.length, 3);
      });
    });

    group('Find and Modify', () {
      test('Update and Return', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation =
            FindAndModifyOperation(collection, query: <String, dynamic>{
          'name': 'Tom',
          'state': 'active',
          'rating': {r'$gt': 10}
        }, sort: <String, dynamic>{
          'rating': 1
        }, update: <String, dynamic>{
          r'$inc': {'score': 1}
        });
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Tom');
        expect(res.value['score'], 5);
      });
      test('Update and Return new', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'name': 'Tom',
              'state': 'active',
              'rating': {r'$gt': 10}
            },
            sort: <String, dynamic>{'rating': 1},
            update: <String, dynamic>{
              r'$inc': {'score': 1}
            },
            returnNew: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Tom');
        expect(res.value['score'], 6);
      });
      test('No update', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'name': 'Tim',
              'state': 'active',
              'rating': {r'$gt': 10}
            },
            sort: <String, dynamic>{'rating': 1},
            update: <String, dynamic>{
              r'$inc': {'score': 1}
            },
            returnNew: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.n, 0);
        expect(res.value, isNull);
      });
      test('Upsert true', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'name': 'Gus',
              'state': 'active',
              'rating': 100
            },
            sort: <String, dynamic>{'rating': 1},
            update: <String, dynamic>{
              r'$inc': {'score': 1}
            },
            upsert: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, TypeMatcher<ObjectId>());
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNull);
      });
      test('Upsert true - returnNew true', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'name': 'Gus',
              'state': 'active',
              'rating': 100
            },
            sort: <String, dynamic>{'rating': 1},
            update: <String, dynamic>{
              r'$inc': {'score': 1}
            },
            upsert: true,
            returnNew: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, TypeMatcher<ObjectId>());
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Gus');
        expect(res.value['score'], 1);
        expect(res.value['_id'], res.lastErrorObject.upserted);
      });

      test('Upsert true ignored - returnNew true', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.insertOne(<String, dynamic>{
          'name': 'Gus',
          'state': 'active',
          'rating': 100,
          'score': 15
        });

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'name': 'Gus',
              'state': 'active',
              'rating': 100
            },
            sort: <String, dynamic>{'rating': 1},
            update: <String, dynamic>{
              r'$inc': {'score': 1}
            },
            upsert: true,
            returnNew: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.upserted, isNull);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Gus');
        expect(res.value['score'], 16);
      });

      test('Remove', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'state': 'active',
            },
            sort: <String, dynamic>{'rating': 1},
            remove: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, isNull);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'George');
        expect(res.value['score'], 8);
        expect(res.value['_id'], 4);
      });
      test('Collation', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertFrenchCafe(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'category': 'cafe',
              'status': 'a',
            },
            sort: <String, dynamic>{'category': 1},
            update: <String, dynamic>{
              r'$set': {'status': 'updated'}
            },
            findAndModifyOptions: FindAndModifyOptions(
                collation: CollationOptions('fr', strength: 1)));
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['category'], 'café');
        expect(res.value['status'], 'A');
      });

      test('Array Filters', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {
            '_id': 1,
            'grades': [95, 92, 90]
          },
          {
            '_id': 2,
            'grades': [98, 100, 102]
          },
          {
            '_id': 3,
            'grades': [95, 110, 100]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'grades': {r'$gte': 100}
            },
            update: <String, dynamic>{
              r'$set': {r'grades.$[element]': 100}
            },
            returnNew: true,
            arrayFilters: [
              {
                'element': {r'$gte': 100}
              }
            ]);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['grades'].last, 100);
        expect(res.value['_id'], 2);
      });

      test('Array Filters on a specific element', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {
            '_id': 1,
            'grades': [
              {'grade': 80, 'mean': 75, 'std': 6},
              {'grade': 85, 'mean': 90, 'std': 4},
              {'grade': 85, 'mean': 85, 'std': 6}
            ]
          },
          {
            '_id': 2,
            'grades': [
              {'grade': 90, 'mean': 75, 'std': 6},
              {'grade': 87, 'mean': 90, 'std': 3},
              {'grade': 85, 'mean': 85, 'std': 4}
            ]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{'_id': 1},
            update: <String, dynamic>{
              r'$set': {r'grades.$[element].mean': 100}
            },
            returnNew: true,
            arrayFilters: [
              {
                'element.grade': {r'$gte': 85}
              }
            ]);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['grades'].last['mean'], 100);
        expect(res.value['_id'], 1);
      });
      test('Aggregation Pipeline', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {
            '_id': 1,
            'grades': [
              {'grade': 80, 'mean': 75, 'std': 6},
              {'grade': 85, 'mean': 90, 'std': 4},
              {'grade': 85, 'mean': 85, 'std': 6}
            ]
          },
          {
            '_id': 2,
            'grades': [
              {'grade': 90, 'mean': 75, 'std': 6},
              {'grade': 87, 'mean': 90, 'std': 3},
              {'grade': 85, 'mean': 85, 'std': 4}
            ]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{'_id': 1},
            update: [
              <String, dynamic>{
                r'$addFields': {
                  r'total': {r'$sum': r'$grades.grade'}
                }
              }
            ],
            returnNew: true);
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.upserted, isNull);

        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['total'], 250);
        expect(res.value['_id'], 1);
      });

      test('Specify Hint', () async {
        if (!running4_4orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertMembers(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.createIndex(keys: {'status': 1});
        await collection.createIndex(key: 'points');

        var famOperation = FindAndModifyOperation(collection,
            query: <String, dynamic>{
              'points': {r'$lte': 20},
              'status': 'P'
            },
            remove: true,
            hintDocument: {'status': 1});
        var res = await famOperation.executeDocument();

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, isNull);

        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['member'], 'abc123');
        expect(res.value['_id'], 1);
      });
    });
    group('Find and Modify - Collection Helper', () {
      test('Update and Return', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where
                .eq('name', 'Tom')
                .eq('state', 'active')
                .eq('rating', {r'$gt': 10}),
            sort: <String, dynamic>{'rating': 1},
            update: ModifierBuilder().inc('score', 1));

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Tom');
        expect(res.value['score'], 5);
      });
      test('Update and Return new', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where
                .eq('name', 'Tom')
                .eq('state', 'active')
                .eq('rating', {r'$gt': 10}),
            sort: <String, dynamic>{'rating': 1},
            update: ModifierBuilder().inc('score', 1),
            returnNew: true);

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Tom');
        expect(res.value['score'], 6);
      });
      test('No update', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where
                .eq('name', 'Tim')
                .eq('state', 'active')
                .eq('rating', {r'$gt': 10}),
            sort: <String, dynamic>{'rating': 1},
            update: ModifierBuilder().inc('score', 1),
            returnNew: true);

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.n, 0);
        expect(res.value, isNull);
      });

      test('Upsert true', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query:
                where.eq('name', 'Gus').eq('state', 'active').eq('rating', 100),
            sort: <String, dynamic>{'rating': 1},
            update: ModifierBuilder().inc('score', 1),
            upsert: true);

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, TypeMatcher<ObjectId>());
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNull);
      });
      test('Upsert true - returnNew true', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query:
                where.eq('name', 'Gus').eq('state', 'active').eq('rating', 100),
            sort: <String, dynamic>{'rating': 1},
            update: ModifierBuilder().inc('score', 1),
            upsert: true,
            returnNew: true);

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, TypeMatcher<ObjectId>());
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Gus');
        expect(res.value['score'], 1);
        expect(res.value['_id'], res.lastErrorObject.upserted);
      });

      test('Upsert true ignored - returnNew true', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.insertOne(<String, dynamic>{
          'name': 'Gus',
          'state': 'active',
          'rating': 100,
          'score': 15
        });

        var res = await collection.modernFindAndModify(
            query:
                where.eq('name', 'Gus').eq('state', 'active').eq('rating', 100),
            sort: <String, dynamic>{'rating': 1},
            update: ModifierBuilder().inc('score', 1),
            upsert: true,
            returnNew: true);

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.upserted, isNull);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'Gus');
        expect(res.value['score'], 16);
      });

      test('Remove', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertPeople(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where.eq('state', 'active'),
            sort: <String, dynamic>{'rating': 1},
            remove: true);

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, isNull);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['name'], 'George');
        expect(res.value['score'], 8);
        expect(res.value['_id'], 4);
      });
      test('Collation', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertFrenchCafe(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where.eq('category', 'cafe').eq('status', 'a'),
            sort: <String, dynamic>{'category': 1},
            update: ModifierBuilder().set('status', 'updated'),
            findAndModifyOptions: FindAndModifyOptions(
                collation: CollationOptions('fr', strength: 1)));

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['category'], 'café');
        expect(res.value['status'], 'A');
      });

      test('Array Filters', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {
            '_id': 1,
            'grades': [95, 92, 90]
          },
          {
            '_id': 2,
            'grades': [98, 100, 102]
          },
          {
            '_id': 3,
            'grades': [95, 110, 100]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where.gte('grades', 100),
            update: ModifierBuilder().set(r'grades.$[element]', 100),
            returnNew: true,
            arrayFilters: [
              {
                'element': {r'$gte': 100}
              }
            ]);

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['grades'].last, 100);
        expect(res.value['_id'], 2);
      });

      test('Array Filters on a specific element', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {
            '_id': 1,
            'grades': [
              {'grade': 80, 'mean': 75, 'std': 6},
              {'grade': 85, 'mean': 90, 'std': 4},
              {'grade': 85, 'mean': 85, 'std': 6}
            ]
          },
          {
            '_id': 2,
            'grades': [
              {'grade': 90, 'mean': 75, 'std': 6},
              {'grade': 87, 'mean': 90, 'std': 3},
              {'grade': 85, 'mean': 85, 'std': 4}
            ]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
            query: where.eq('_id', 1),
            update: ModifierBuilder().set(r'grades.$[element].mean', 100),
            returnNew: true,
            arrayFilters: [
              {
                'element.grade': {r'$gte': 85}
              }
            ]);

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['grades'].last['mean'], 100);
        expect(res.value['_id'], 1);
      });
      test('Aggregation Pipeline', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.insertMany([
          {
            '_id': 1,
            'grades': [
              {'grade': 80, 'mean': 75, 'std': 6},
              {'grade': 85, 'mean': 90, 'std': 4},
              {'grade': 85, 'mean': 85, 'std': 6}
            ],
            'addend1': Rational.fromInt(1) / Rational.fromInt(3),
            'addend2': Rational.fromInt(2) / Rational.fromInt(3)
          },
          {
            '_id': 2,
            'grades': [
              {'grade': 90, 'mean': 75, 'std': 6},
              {'grade': 87, 'mean': 90, 'std': 3},
              {'grade': 85, 'mean': 85, 'std': 4}
            ]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var res = await collection.modernFindAndModify(
          query: where.eq('_id', 1),
          update: AggregationPipelineBuilder()
              .addStage(AddFields({
                r'total': {r'$sum': r'$grades.grade'},
                r'decimal': {
                  r'$sum': [r'$addend1', r'$addend2']
                },
                r'decimal2': {
                  r'$sum': [r'$addend1', r'$addend1', r'$addend1']
                }
              }))
              .build(),
          returnNew: true,
        );

        expect(res.lastErrorObject.updatedExisting, isTrue);
        expect(res.lastErrorObject.upserted, isNull);

        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['total'], 250);
        expect(res.value['decimal'], Rational.fromInt(1));
        expect(res.value['decimal2'],
            Rational.parse('0.9999999999999999999999999999999999'));

        expect(res.value['_id'], 1);
      });

      test('Specify Hint', () async {
        if (!running4_4orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertMembers(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.createIndex(keys: {'status': 1});
        await collection.createIndex(key: 'points');

        var res = await collection.modernFindAndModify(
            query: where.lte('points', 20).eq('status', 'P'),
            remove: true,
            hintDocument: {'status': 1});

        expect(res.lastErrorObject.updatedExisting, isFalse);
        expect(res.lastErrorObject.upserted, isNull);

        expect(res.lastErrorObject.n, 1);
        expect(res.value, isNotNull);
        expect(res.value['member'], 'abc123');
        expect(res.value['_id'], 1);
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
