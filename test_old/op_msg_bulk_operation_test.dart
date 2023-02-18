import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/base/update_union.dart';
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/utils/query_union.dart';
import 'package:test/test.dart';

import '../test/utils/insert_data.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

final Matcher throwsMongoDartError = throwsA(TypeMatcher<MongoDartError>());

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

  group('Bulk Operations', () {
    var cannotRunTests = false;
    //var isReplicaSet = false;
    var isStandalone = false;
    //var isSharded = false;
    //var running4_4orGreater = false;
    //var running4_2orGreater = false;

    setUp(() async {
      await initializeDatabase();
      if (!db.server.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
      var serverFcv = db.server.serverCapabilities.fcv ?? '0.0';
      if (serverFcv.compareTo('4.4') != -1) {
        //running4_4orGreater = true;
      }
      if (serverFcv.compareTo('4.2') != -1) {
        //running4_2orGreater = true;
      }
      //isReplicaSet = db.server.serverCapabilities.isReplicaSet;
      isStandalone = db.server.serverCapabilities.isStandalone;
      //isSharded = db.server.serverCapabilities.isShardedCluster;
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Utils', () {
      test('SplitInputOrigins', () {
        var saveMaxDocs = MongoModernMessage.maxWriteBatchSize;
        MongoModernMessage.maxWriteBatchSize = 5;
        var originMap = {0: 0, 3: 1, 7: 2, 12: 3};
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);
        var bulk = OrderedBulk(collection);
        var ret = bulk.splitInputOrigins(originMap, 22);
        MongoModernMessage.maxWriteBatchSize = saveMaxDocs;
        expect(ret, isNotNull);
        expect(ret, isNotEmpty);
        expect(ret.length, 5);
        expect(ret[0][0], 0);
        expect(ret[0][3], 1);
        expect(ret[1][0], 1);
        expect(ret[1][1], null);
        expect(ret[1][2], 2);
        expect(ret[1][4], null);
        expect(ret[2][0], 2);
        expect(ret[2][2], 3);
        expect(ret[2][4], null);
        expect(ret[3][0], 3);
        expect(ret[4][0], 3);
      });
      test('SplitInputOrigins - 2', () {
        var saveMaxDocs = MongoModernMessage.maxWriteBatchSize;
        MongoModernMessage.maxWriteBatchSize = 5;
        var originMap = {0: 0, 4: 1, 5: 2, 9: 3, 10: 4};
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);
        var bulk = OrderedBulk(collection);
        var ret = bulk.splitInputOrigins(originMap, 22);
        MongoModernMessage.maxWriteBatchSize = saveMaxDocs;
        expect(ret, isNotNull);
        expect(ret, isNotEmpty);
        expect(ret.length, 5);
        expect(ret[0][0], 0);
        expect(ret[0][4], 1);
        expect(ret[1][0], 2);
        expect(ret[1][1], null);
        expect(ret[1][3], null);
        expect(ret[1][4], 3);
        expect(ret[2][0], 4);
        expect(ret[2][2], null);
        expect(ret[2][4], null);
        expect(ret[3][0], 4);
        expect(ret[4][0], 4);
      });
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

        var ret = await bulk.executeDocument(db.server);

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

        var ret = await bulk.executeDocument(db.server);

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
        expect(ret.writeErrors.first.operationInputIndex, 1);
        expect(ret.writeErrors.first.index, 20001);

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

        var ret = await bulk.executeDocument(db.server);

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

        var ret = await bulk.executeDocument(db.server);

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

        var bulk = UnorderedBulk(collection,
            writeConcern: WriteConcern(w: primaryAcknowledged));
        bulk.deleteMany(DeleteManyStatement(QueryUnion({'status': 'D'})));

        bulk.deleteOne(DeleteOneStatement(
            QueryUnion({'cust_num': 99999, 'item': 'abc123', 'status': 'A'})));

        var ret = await bulk.executeDocument(db.server);

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
      test('Unordered Bulk - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var retOrders = await insertOrders(collection);
        expect(retOrders.ok, 1.0);
        expect(retOrders.isSuccess, isTrue);

        var ret = await collection.bulkWrite([
          {
            bulkDeleteMany: {
              bulkFilter: {'status': 'D'},
            }
          },
          {
            'deleteOne': {
              'filter': {'cust_num': 99999, 'item': 'abc123', 'status': 'A'}
            }
          }
        ], ordered: false);

        /* var bulk = UnorderedBulk(collection, writeConcern: WriteConcern(w: 1));
        bulk.deleteMany(DeleteManyStatement({'status': 'D'}));

        bulk.deleteOne(DeleteOneStatement(
            {'cust_num': 99999, 'item': 'abc123', 'status': 'A'}));

        var ret = await bulk.executeDocument(); */

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
      test('Ordered Bulk', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var retOrders = await insertOrders(collection);
        expect(retOrders.ok, 1.0);
        expect(retOrders.isSuccess, isTrue);

        var bulk = OrderedBulk(collection,
            writeConcern: WriteConcern(w: primaryAcknowledged));
        bulk.deleteMany(DeleteManyStatement(QueryUnion({'status': 'D'})));

        bulk.deleteOne(DeleteOneStatement(
            QueryUnion({'cust_num': 99999, 'item': 'abc123', 'status': 'A'})));

        var ret = await bulk.executeDocument(db.server);

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

    group('Bulk update', () {
      test('Unordered Bulk', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var retOrders = await insertOrders(collection);
        expect(retOrders.ok, 1.0);
        expect(retOrders.isSuccess, isTrue);

        var bulk = UnorderedBulk(collection,
            writeConcern: WriteConcern(w: primaryAcknowledged));
        bulk.updateMany(UpdateManyStatement(QueryUnion(where.eq('status', 'D')),
            UpdateUnion(ModifierBuilder().set('status', 'd'))));

        bulk.updateOne(UpdateOneStatement(
            QueryUnion({'cust_num': 99999, 'item': 'abc123', 'status': 'A'}),
            UpdateUnion(ModifierBuilder().inc('ordered', 1))));

        bulk.replaceOne(ReplaceOneStatement(
            QueryUnion({'cust_num': 12345, 'item': 'tst24', 'status': 'D'}),
            UpdateUnion(
                {'cust_num': 12345, 'item': 'tst24', 'status': 'Replaced'}),
            upsert: true));
        var ret = await bulk.executeDocument(db.server);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.update);
        expect(ret.nUpserted, 1);
        expect(ret.nModified, 14);
        expect(ret.nMatched, 15);
        expect(ret.nRemoved, 0);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);
      test('Ordered Bulk', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var retOrders = await insertOrders(collection);
        expect(retOrders.ok, 1.0);
        expect(retOrders.isSuccess, isTrue);

        var bulk = OrderedBulk(collection,
            writeConcern: WriteConcern(w: primaryAcknowledged));
        bulk.updateMany(UpdateManyStatement(QueryUnion(where.eq('status', 'D')),
            UpdateUnion(ModifierBuilder().set('status', 'd'))));

        bulk.updateOne(UpdateOneStatement(
            QueryUnion({'cust_num': 99999, 'item': 'abc123', 'status': 'A'}),
            UpdateUnion(ModifierBuilder().inc('ordered', 1))));
        bulk.replaceOne(ReplaceOneStatement(
            QueryUnion({'cust_num': 12345, 'item': 'tst24', 'status': 'D'}),
            UpdateUnion(
                {'cust_num': 12345, 'item': 'tst24', 'status': 'Replaced'}),
            upsert: true));
        var ret = await bulk.executeDocument(db.server);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.update);
        expect(ret.nUpserted, 1);
        expect(ret.nModified, 14);
        expect(ret.nMatched, 15);
        expect(ret.nRemoved, 0);
        // Todo check ids and documents
        //expect(ret.ids.first, 2);
        //expect(ret.documents.first['name'], 'Stephen');
      }, skip: cannotRunTests);
      test('Ordered Bulk - collection helper', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var retOrders = await insertOrders(collection);
        expect(retOrders.ok, 1.0);
        expect(retOrders.isSuccess, isTrue);

        var ret = await collection.bulkWrite([
          {
            bulkUpdateMany: {
              bulkFilter: {'status': 'D'},
              bulkUpdate: {
                r'$set': {'status': 'd'}
              }
            }
          },
          {
            bulkUpdateOne: {
              bulkFilter: {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
              bulkUpdate: {
                r'$inc': {'ordered': 1}
              }
            }
          },
          {
            bulkReplaceOne: {
              bulkFilter: {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
              bulkReplacement: {
                'cust_num': 12345,
                'item': 'tst24',
                'status': 'Replaced'
              },
              bulkUpsert: true
            }
          }
        ], ordered: true);

        /* var bulk = OrderedBulk(collection, writeConcern: WriteConcern(w: 1));
        bulk.updateMany(UpdateManyStatement(
            where.eq('status', 'D').map[key$Query],
            ModifierBuilder().set('status', 'd').map));

        bulk.updateOne(UpdateOneStatement(
            {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
            ModifierBuilder().inc('ordered', 1).map));
        bulk.replaceOne(ReplaceOneStatement({
          'cust_num': 12345,
          'item': 'tst24',
          'status': 'D'
        }, {
          'cust_num': 12345,
          'item': 'tst24',
          'status': 'Replaced'
        }, upsert: true));
        var ret = await bulk.executeDocument(); */

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, WriteCommandType.update);
        expect(ret.nUpserted, 1);
        expect(ret.nModified, 14);
        expect(ret.nMatched, 15);
        expect(ret.nRemoved, 0);
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
        bulk.deleteOne(DeleteOneStatement(QueryUnion({'_id': 2})));
        bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
        bulk.deleteOne(DeleteOneStatement(QueryUnion({'_id': 4})));
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument(db.server);

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
        bulk.deleteOne(DeleteOneStatement(QueryUnion({'_id': 2})));
        bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
        bulk.deleteMany(DeleteManyStatement(QueryUnion({
          'age': {r'$gt': 28}
        })));
        bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});

        var ret = await bulk.executeDocument(db.server);

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
      test('Ordered Bulk - "One" method types', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 3, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        var ret = await collection.bulkWrite([
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 5,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          }
        ]);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 2);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic
        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 2);
        //expect(ret.ids?[0], 4);
        expect(ret.upserted, isEmpty);

        var findResult = await collection.find().toList();
        expect(findResult.length, 4);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Taeln');
      }, skip: cannotRunTests);
      test('Ordered Bulk - "One" method types - with error', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 5, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        var ret = await collection.bulkWrite([
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 5,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          }
        ]);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 1);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.writeCommandType, WriteCommandType.insert);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 0);
        expect(ret.nMatched, 0);
        expect(ret.nRemoved, 0);
        // TODO update record logic

        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 1);
        //expect(ret.ids?.first, 4);
        expect(ret.upserted, isEmpty);
        expect(ret.writeErrors.first.index, 1);
        expect(ret.writeErrors.first.operationInputIndex, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 4);
        expect(findResult.first['char'], 'Brisbane');
        expect(findResult[1]['char'], 'Eldon');
        expect(findResult.last['char'], 'Dithras');
      }, skip: cannotRunTests);

      test('Ordered Bulk - "All" method types', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var ret = await collection.bulkWrite([
          {
            bulkInsertMany: {
              bulkDocuments: [
                {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
                {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
                {'_id': 3, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
              ]
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 5,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          }
        ]);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.isSuccess, isTrue);
        expect(ret.isPartialSuccess, isFalse);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic

        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 5);
        //expect(ret.ids?.first, 1);
        expect(ret.upserted, isEmpty);

        var findResult = await collection.find().toList();
        expect(findResult.length, 4);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Taeln');
      }, skip: cannotRunTests);

      test('Ordered Bulk - "All" method types fromMap', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var bulk = OrderedBulk(collection);

        bulk.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 3, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        bulk.insertOne(
            {'_id': 4, 'char': 'Dithras', 'class': 'barbarian', 'lvl': 4});
        bulk.insertOne(
            {'_id': 5, 'char': 'Taeln', 'class': 'fighter', 'lvl': 3});
        bulk.updateOneFromMap({
          'filter': {'char': 'Eldon'},
          'update': {
            r'$set': {'status': 'Critical Injury'}
          }
        });
        bulk.deleteOneFromMap({
          'filter': {'char': 'Brisbane'}
        });
        bulk.replaceOneFromMap({
          'filter': {'char': 'Meldane'},
          'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
        });

        var ret = await bulk.executeDocument(db.server);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isFalse);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 5);
        expect(ret.isSuccess, isTrue);
        expect(ret.isPartialSuccess, isFalse);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic
        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 5);
        //expect(ret.ids?.first, 1);
        expect(ret.upserted, isEmpty);

        var findResult = await collection.find().toList();
        expect(findResult.length, 4);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Taeln');
      }, skip: cannotRunTests);

      test('Ordered Bulk - "One" method types - with error - 2', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 3, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        var ret = await collection.bulkWrite([
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 5,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          },
          {
            'insertOne': {
              'document': {'_id': 4, 'char': 'Amber', 'class': 'monk', 'lvl': 3}
            }
          },
        ]);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 2);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.writeCommandType, null);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic
        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 2);
        //expect(ret.ids?.first, 4);
        expect(ret.upserted, isEmpty);
        expect(ret.writeErrors.first.index, 0);
        expect(ret.writeErrors.first.operationInputIndex, 5);

        var findResult = await collection.find().toList();
        expect(findResult.length, 4);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Taeln');
      }, skip: cannotRunTests);
      test('Unordered Bulk - "One" method types - with error', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 5, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        var ret = await collection.bulkWrite([
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 5,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          }
        ], ordered: false);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 1);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.writeCommandType, null);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic
        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 1);
        //expect(ret.ids?.first, 4);
        expect(ret.upserted, isEmpty);
        expect(ret.writeErrors.first.index, 1);
        expect(ret.writeErrors.first.operationInputIndex, 1);

        var findResult = await collection.find().toList();
        expect(findResult.length, 3);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Dithras');
      }, skip: cannotRunTests);

      test('Unordered Bulk - "One" method types - with error - 2', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 3, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        var ret = await collection.bulkWrite([
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 5,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          },
          {
            'insertOne': {
              'document': {'_id': 4, 'char': 'Amber', 'class': 'monk', 'lvl': 3}
            }
          },
        ], ordered: false);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 2);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.writeCommandType, null);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic
        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 2);
        //expect(ret.ids?.first, 4);
        expect(ret.upserted, isEmpty);
        expect(ret.writeErrors.first.index, 2);
        expect(ret.writeErrors.first.operationInputIndex, 5);

        var findResult = await collection.find().toList();
        expect(findResult.length, 4);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Taeln');
      }, skip: cannotRunTests);
      test('Unordered Bulk - "One" method types', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'Brisbane', 'class': 'monk', 'lvl': 4},
          {'_id': 2, 'char': 'Eldon', 'class': 'alchemist', 'lvl': 3},
          {'_id': 3, 'char': 'Meldane', 'class': 'ranger', 'lvl': 3}
        ]);

        var ret = await collection.bulkWrite([
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Dithras',
                'class': 'barbarian',
                'lvl': 4
              }
            }
          },
          {
            'insertOne': {
              'document': {
                '_id': 4,
                'char': 'Taeln',
                'class': 'fighter',
                'lvl': 3
              }
            }
          },
          {
            'updateOne': {
              'filter': {'char': 'Eldon'},
              'update': {
                r'$set': {'status': 'Critical Injury'}
              }
            }
          },
          {
            'deleteOne': {
              'filter': {'char': 'Brisbane'}
            }
          },
          {
            'replaceOne': {
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            }
          }
        ], ordered: false);

        expect(ret.ok, 1.0);
        expect(ret.operationSucceeded, isTrue);
        expect(ret.hasWriteErrors, isTrue);
        expect(ret.hasWriteConcernError, isFalse);
        expect(ret.nInserted, 1);
        expect(ret.isSuccess, isFalse);
        expect(ret.isPartialSuccess, isTrue);
        expect(ret.writeCommandType, isNull);
        expect(ret.nUpserted, 0);
        expect(ret.nModified, 2);
        expect(ret.nMatched, 2);
        expect(ret.nRemoved, 1);
        // TODO update record logic

        //expect(ret.ids, isNotNull);
        //expect(ret.ids?.length, 1);
        //expect(ret.ids?[0], 4);
        expect(ret.upserted, isEmpty);

        var findResult = await collection.find().toList();
        expect(findResult.length, 3);
        expect(findResult.first['char'], 'Eldon');
        expect(findResult[1]['char'], 'Tanys');
        expect(findResult.last['char'], 'Dithras');
      }, skip: cannotRunTests);

      test('Ordered Bulk Write with Write Concern', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'goblin', 'rating': 1, 'encounter': 0.24},
          {'_id': 2, 'char': 'hobgoblin', 'rating': 1.5, 'encounter': 0.30},
          {'_id': 3, 'char': 'ogre', 'rating': 3, 'encounter': 0.2},
          {'_id': 4, 'char': 'ogre berserker', 'rating': 3.5, 'encounter': 0.12}
        ]);

        var ret = await collection.bulkWrite([
          {
            bulkUpdateMany: {
              bulkFilter: {
                'rating': {r'$gte': 3}
              },
              bulkUpdate: {
                r'$inc': {'encounter': 0.1}
              }
            },
          },
          {
            bulkUpdateMany: {
              bulkFilter: {
                'rating': {r'$lt': 2}
              },
              bulkUpdate: {
                r'$inc': {'encounter': -0.25}
              }
            },
          },
          {
            bulkDeleteMany: {
              bulkFilter: {
                'encounter': {r'$lt': 0}
              }
            }
          },
          {
            bulkInsertOne: {
              bulkDocument: {
                '_id': 5,
                'char': 'ogrekin',
                'rating': 2,
                'encounter': 0.31
              }
            }
          }
        ],
            ordered: true,
            writeConcern: WriteConcern(
              w: W(4),
              wtimeout: 100,
            ));

        if (isStandalone) {
          expect(ret.ok, 0.0);
          expect(ret.operationSucceeded, isFalse);
          expect(ret.errmsg, isNotEmpty);
        } else {
          expect(ret.ok, 1.0);
          expect(ret.operationSucceeded, isTrue);
          expect(ret.isSuccess, isFalse);
          expect(ret.isSuspendedSuccess, isTrue);
          expect(ret.hasWriteErrors, isFalse);
          expect(ret.hasWriteConcernError, isTrue);
          expect(ret.nInserted, 1);
          expect(ret.operationSucceeded, isTrue);
          expect(ret.writeCommandType, isNull);
          expect(ret.nUpserted, 0);
          expect(ret.nModified, 4);
          expect(ret.nMatched, 4);
          expect(ret.nRemoved, 1);
          // TODO update record logic

          //expect(ret.ids, isNotNull);
          //expect(ret.ids?.length, 1);
          //expect(ret.ids?[0], 5);
          expect(ret.upserted, isEmpty);
          var findResult = await collection.find().toList();
          expect(findResult.length, 4);
          expect(findResult.first['char'], 'hobgoblin');
          expect(findResult[1]['char'], 'ogre');
          expect(findResult.last['char'], 'ogrekin');
        }
      }, skip: cannotRunTests);
      test('Unordered Bulk Write with Write Concern', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'_id': 1, 'char': 'goblin', 'rating': 1, 'encounter': 0.24},
          {'_id': 2, 'char': 'hobgoblin', 'rating': 1.5, 'encounter': 0.30},
          {'_id': 3, 'char': 'ogre', 'rating': 3, 'encounter': 0.2},
          {'_id': 4, 'char': 'ogre berserker', 'rating': 3.5, 'encounter': 0.12}
        ]);

        var ret = await collection.bulkWrite([
          {
            bulkUpdateMany: {
              bulkFilter: {
                'rating': {r'$gte': 3}
              },
              bulkUpdate: {
                r'$inc': {'encounter': 0.1}
              }
            },
          },
          {
            bulkUpdateMany: {
              bulkFilter: {
                'rating': {r'$lt': 2}
              },
              bulkUpdate: {
                r'$inc': {'encounter': -0.25}
              }
            },
          },
          {
            bulkDeleteMany: {
              bulkFilter: {
                'encounter': {r'$lt': 0}
              }
            }
          },
          {
            bulkInsertOne: {
              bulkDocument: {
                '_id': 5,
                'char': 'ogrekin',
                'rating': 2,
                'encounter': 0.31
              }
            }
          }
        ], ordered: false, writeConcern: WriteConcern(w: W(4), wtimeout: 100));

        if (isStandalone) {
          expect(ret.ok, 0.0);
          expect(ret.operationSucceeded, isFalse);
          expect(ret.errmsg, isNotEmpty);
        } else {
          expect(ret.ok, 1.0);
          expect(ret.operationSucceeded, isTrue);
          expect(ret.isSuccess, isFalse);
          expect(ret.isSuspendedSuccess, isTrue);
          expect(ret.hasWriteErrors, isFalse);
          expect(ret.hasWriteConcernError, isTrue);
          expect(ret.nInserted, 1);
          expect(ret.operationSucceeded, isTrue);
          expect(ret.writeCommandType, isNull);
          expect(ret.nUpserted, 0);
          expect(ret.nModified, 4);
          expect(ret.nMatched, 4);
          expect(ret.nRemoved, 1);
          // TODO update record logic
          //expect(ret.ids, isNotNull);
          //expect(ret.ids?.length, 1);
          //expect(ret.ids?[0], 5);
          expect(ret.upserted, isEmpty);
          var findResult = await collection.find().toList();
          expect(findResult.length, 4);
          expect(findResult.first['char'], 'hobgoblin');
          expect(findResult[1]['char'], 'ogre');
          expect(findResult.last['char'], 'ogrekin');
        }
      }, skip: cannotRunTests);
    });
  });
  tearDownAll(() async {
    await client.connect();
    db = client.db();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await client.close();
  });
}
