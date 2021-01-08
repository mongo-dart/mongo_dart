import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/delete_operation/delete_request.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_options.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_request.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_request.dart';
import 'package:mongo_dart/src/database/operation/parameters/collation_options.dart';
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

  group('Write Operations', () {
    var cannotRunTests = false;
    var running4_4orGreater = false;
    var isReplicaSet = false;
    var isStandalone = false;
    var isSharded = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
      var serverFcv = db?.masterConnection?.serverStatus?.fcv ?? '0.0';
      if (serverFcv.compareTo('4.4') != -1) {
        running4_4orGreater = true;
      }
      isReplicaSet = db?.masterConnection?.serverStatus?.isReplicaSet ?? false;
      isStandalone = db?.masterConnection?.serverStatus?.isStandalone ?? false;
      isSharded = db?.masterConnection?.serverStatus?.isShardedCluster ?? false;
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
            DeleteOneOperation(collection, DeleteOneRequest({}));
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
            DeleteOneOperation(collection, DeleteOneRequest({key_Id: 7}));
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
            DeleteOneOperation(collection, DeleteOneRequest({'status': 'D'}));
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
            DeleteManyOperation(collection, DeleteManyRequest({}));
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
            DeleteManyOperation(collection, DeleteManyRequest({key_Id: 7}));
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

        var deleteOperation =
            DeleteManyOperation(collection, DeleteManyRequest({'status': 'D'}));
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
            collection, DeleteManyRequest({}),
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
          DeleteManyRequest({'category': 'cafe', 'status': 'a'},
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
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await insertMembers(collection);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        await collection.createIndex(keys: {'status': 1});
        await collection.createIndex(keys: {'points': 1});

        var deleteOperation = DeleteManyOperation(
          collection,
          DeleteManyRequest({
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
      }, skip: cannotRunTests || !running4_4orGreater);
    });
  });
  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
