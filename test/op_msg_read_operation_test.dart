@Timeout(Duration(seconds: 30))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/wrapper/create_collection/create_collection_options.dart';
import 'package:mongo_dart/src/database/operation/commands/aggreagation_commands/aggregate/aggregate_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/aggreagation_commands/wrapper/change_stream/change_stream_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_options.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/get_more_command/get_more_command.dart';
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

  group('Read Operations', () {
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

    test('Simple read', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = await collection.modernFind().toList();
      expect(result.length, 10000);
    }, skip: cannotRunTests);

    test('Simple read - using stream', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = [];
      var stream = collection.modernFind();
      await for (var element in stream) {
        result.add(element);
      }
      expect(result.length, 10000);
    }, skip: cannotRunTests);
    test('Simple read - using stream from cursor', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = [];
      var cursor = ModernCursor(FindOperation(collection));
      await for (var element in cursor.stream) {
        result.add(element);
      }
      expect(result.length, 10000);
    }, skip: cannotRunTests);

    test('Simple read error- using wrong stream from cursor', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = [];
      var cursor = ModernCursor(FindOperation(collection));
      try {
        await for (var element in cursor.changeStream) {
          result.add(element);
        }
        // should not pass by here but catch the error
        expect('No Error', 'MongoDartError');
      } on MongoDartError {
        // OK!!
      } catch (e) {
        expect('$e', 'MongoDartError');
      }
    }, skip: cannotRunTests);

    test('Simple read from capped collection', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await db.createCollection(collectionName,
          createCollectionOptions:
              CreateCollectionOptions(capped: true, size: 5242880, max: 5000));
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      await insertManyDocuments(collection, 10000);
      var result = await collection.modernFind().toList();

      expect(result.length, 5000);
    }, skip: cannotRunTests);

    group('Normal Cursor', () {
      test('Simple read from capped collection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 120);

        var cursor = await ModernCursor(FindOperation(collection));

        expect(cursor.state, State.INIT);

        await cursor.nextObject();

        // calling getMoreCommand after having a Cursor object
        // should not be done in production, as the Cursor instance
        // state will not be updated.
        // more, notice that with cursor nextObject we got one document,
        // but, internally, the cursor have already fetched from the server
        // a default 101 documents, so, when we run the getMore command
        // only 19 can be retrieved.
        var command = GetMoreCommand(collection, cursor.cursorId);
        var resultCommand = await command.execute();
        expect(resultCommand, isNotNull);
        expect(resultCommand[keyCursor], isNotNull);

        Map cursorMap = resultCommand[keyCursor];
        expect(cursorMap[keyFirstBatch], isNull);
        expect(cursorMap[keyNextBatch], isNotEmpty);
        expect(cursorMap[keyNextBatch].length, 19);
        expect(cursorMap[keyId], isZero);
        // Server automatically closed on end of selection
        /*  expect(cursor.state, State.CLOSED);
        expect(cursor.cursorId.value, isZero); */
      }, skip: cannotRunTests);
    });

    group('Tailable Cursor', () {
      test('Simple read from capped collection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 110);
        var doc = await FindOperation(collection,
                findOptions: FindOptions(tailable: true))
            .execute();

        var cursor = ModernCursor.fromOpenId(
            collection, BsonLong((doc[keyCursor] as Map)[keyId] as int),
            tailable: true);

        expect(cursor.state, State.OPEN);

        var cursorResult = await cursor.nextObject();
        expect(cursor.state, State.OPEN);
        expect(cursor.cursorId.value, isPositive);
        expect(cursorResult['a'], 101);
        expect(cursorResult, isNotNull);

        var aResult = (cursorResult['a'] as int) + 1;
        var got110 = false;
        cursor.stream.listen((event) {
          expect(event['a'], aResult++);
          if (event['a'] == 110) {
            got110 = true;
          }
        });

        expect(cursor.state, State.OPEN);

        await Future.delayed(Duration(seconds: 3));

        await collection.insertOne({'a': 110});

        await Future.doWhile(() async {
          if (got110) {
            await cursor.close();
            return false;
          }
          await Future.delayed(Duration(seconds: 2));

          return true;
        });
        expect(cursor.state, State.CLOSED);
      });
      test('Simple read from capped collection with awaitData', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 110);
        var doc = await FindOperation(collection,
                findOptions: FindOptions(tailable: true, awaitData: true))
            .execute();

        var cursor = ModernCursor.fromOpenId(
            collection, BsonLong((doc[keyCursor] as Map)[keyId] as int),
            tailable: true);

        expect(cursor.state, State.OPEN);

        var cursorResult = await cursor.nextObject();
        expect(cursor.state, State.OPEN);
        expect(cursor.cursorId.value, isPositive);
        expect(cursorResult['a'], 101);
        expect(cursorResult, isNotNull);

        var aResult = (cursorResult['a'] as int) + 1;
        var got110 = false;
        var got111 = false;

        cursor.stream.listen((event) {
          expect(event['a'], aResult++);
          if (event['a'] == 110) {
            got110 = true;
          } else if (event['a'] == 111) {
            got111 = true;
          }
        });

        expect(cursor.state, State.OPEN);

        await Future.delayed(Duration(seconds: 2));

        await collection.insertOne({'a': 110});

        await Future.doWhile(() async {
          if (got111) {
            await cursor.close();
            return false;
          } else if (got110) {
            await collection.insertOne({'a': 111});
          }
          await Future.delayed(Duration(seconds: 1));

          return true;
        });
        expect(cursor.state, State.CLOSED);
      });

      // Reading with a tailable cursor on a capped collection
      // automatically closes the cursor if the result of the selection is empty
      test('Read from empty collection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        var cursor = ModernCursor(FindOperation(collection,
            findOptions: FindOptions(tailable: true)));
        expect(cursor.state, State.INIT);

        expect(() => cursor.nextObject(), throwsMongoDartError);
      });

      test('Read from empty selection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'test': 1, 'state': 'A'},
          {'test': 2, 'state': 'B'},
          {'test': 3, 'state': 'A'},
          {'test': 4, 'state': 'A'}
        ]);
        var cursor = ModernCursor(FindOperation(collection,
            filter: <String, Object>{'state': 'C'},
            findOptions: FindOptions(tailable: true)));
        expect(cursor.state, State.INIT);

        var cursorResult = await cursor.nextObject();
        expect(cursorResult, isNull);
        expect(cursor.state, State.OPEN);
        expect(cursor.cursorId.value, isNonZero);

        await cursor.close();
      });
    }, skip: cannotRunTests);
  });

  group('Aggregate', () {
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

    test('Simple Aggregate', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      await collection.insertMany(<Map<String, dynamic>>[
        {'game': 'At the Gates of Loyang', 'cost': Rational.parse('15.20')},
        {'game': 'Age of Steam', 'cost': Rational.parse('16.80')},
        {'game': 'Fresco', 'cost': Rational.parse('13')}
      ]);

      var pipeline = AggregationPipelineBuilder().addStage(Group(
          id: 'games',
          fields: {'total': Sum(Field('cost')), 'avg': Avg(Field('cost'))}));

      var result = await collection.modernAggregate(pipeline).toList();
      print(result);
      expect(result.first[key_Id], 'games');
      expect(result.first['avg'], Rational.fromInt(15));
      expect(result.first['total'], Rational.fromInt(45));
    }, skip: cannotRunTests);

    group('admin/diagnostic pipeline', () {
      test('currentOp', () async {
        var stream = db.aggregate([
          {
            r'$currentOp': {'allUsers': true, 'idleConnections': true}
          },
          {
            r'$match': {
              'active': true,
              if (db.masterConnection.serverCapabilities.isShardedCluster)
                'op': 'getmore'
              else
                'command.aggregate': 1
            }
          }
        ]);

        var resultList = await stream.toList();
        if (db.masterConnection.serverCapabilities.fcv.compareTo('4.2') == -1) {
          if (db.masterConnection.serverCapabilities.isShardedCluster) {
            // one command per shard
            expect(resultList, isNotEmpty);
            expect(resultList.first['op'], 'getmore');
          } else {
            expect(resultList.length, 1);
            expect(resultList.first['op'], 'command');
          }
        } else {
          if (db.masterConnection.serverCapabilities.isShardedCluster) {
            // one command per shard
            expect(resultList, isNotEmpty);
            expect(resultList.first['type'], 'op');
            expect(resultList.first['op'], 'getmore');
          } else {
            expect(resultList.length, 1);
            expect(resultList.first['type'], 'op');
            expect(resultList.first['op'], 'command');
          }
        }
      });

      test('listLocalSessions', () async {
        var result = db.aggregate([
          {
            r'$listLocalSessions': {'allUsers': true}
          },
          {
            r'$match': {'active': true, 'command.aggregate': 1}
          }
        ]);

        var resultList = await result.toList();
        expect(resultList.length, 0);
      });
    });

    group('Normal Cursor', () {
      test('Aggregate', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var toInsert = <Map<String, dynamic>>[];

        // Avg 1 with 1 rating
        toInsert.add({
          'game': 'At the Gates of Loyang',
          'player': 'Dallas',
          'rating': 1,
          'v': 1
        });

        // Avg 3 with 1 rating
        toInsert.add(
            {'game': 'Age of Steam', 'player': 'Paul', 'rating': 3, 'v': 1});

        // Avg 2 with 2 ratings
        toInsert.add({'game': 'Fresco', 'player': 'Erin', 'rating': 3, 'v': 1});
        toInsert
            .add({'game': 'Fresco', 'player': 'Dallas', 'rating': 1, 'v': 1});

        // Avg 3.5 with 4 ratings
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Paul', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Dallas',
          'rating': 4,
          'v': 1
        });
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Anthony',
          'rating': 2,
          'v': 1
        });

        // Avg 4.5 with 4 ratings (counting only highest v)
        toInsert
            .add({'game': 'Dominion', 'player': 'Paul', 'rating': 5, 'v': 2});
        toInsert
            .add({'game': 'Dominion', 'player': 'Erin', 'rating': 4, 'v': 1});
        toInsert
            .add({'game': 'Dominion', 'player': 'Dallas', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Dominion', 'player': 'Anthony', 'rating': 5, 'v': 1});

        // Avg 5 with 2 ratings
        toInsert
            .add({'game': 'Pandemic', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert
            .add({'game': 'Pandemic', 'player': 'Dallas', 'rating': 5, 'v': 1});

        await collection.insertMany(toInsert);

        // Avg player ratings
        // Dallas = 3, Anthony 3.5, Paul = 4, Erin = 4.25
/* We want equivalent of this when used on the mongo shell.
 * (Should be able to just copy and paste below once test is run and failed once)
db.runCommand(
{ aggregate : "testAggregate", pipeline : [
{"$group": {
      "_id": { "game": "$game", "player": "$player" },
      "rating": { "$sum": "$rating" } } },
{"$group": {
        "_id": "$_id.game",
        "avgRating": { "$avg": "$rating" } } },
{ "$sort": { "_id": 1 } }
]});
 */
        var pipeline = <Map<String, Object>>[];
        var p1 = {
          r'$group': {
            '_id': {'game': r'$game', 'player': r'$player'},
            'rating': {r'$sum': r'$rating'}
          }
        };
        var p2 = {
          r'$group': {
            '_id': r'$_id.game',
            'avgRating': {r'$avg': r'$rating'}
          }
        };
        var p3 = {
          r'$sort': {'_id': 1}
        };

        pipeline.add(p1);
        pipeline.add(p2);
        pipeline.add(p3);

        expect(p1['\u0024group'], isNotNull);
        expect(p1[r'$group'], isNotNull);

        var aggregateOperation =
            AggregateOperation(pipeline, collection: collection);
        var v = await aggregateOperation.execute();
        var cursor = v[keyCursor] as Map;
        var result = cursor[keyFirstBatch] as List;
        expect(result.first[key_Id], 'Age of Steam');
        expect(result.first['avgRating'], 3);
      });

      test('Aggregate With Cursor Batch Size', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var toInsert = <Map<String, dynamic>>[];

        // Avg 1 with 1 rating
        toInsert.add({
          'game': 'At the Gates of Loyang',
          'player': 'Dallas',
          'rating': 1,
          'v': 1
        });

        // Avg 3 with 1 rating
        toInsert.add(
            {'game': 'Age of Steam', 'player': 'Paul', 'rating': 3, 'v': 1});

        // Avg 2 with 2 ratings
        toInsert.add({'game': 'Fresco', 'player': 'Erin', 'rating': 3, 'v': 1});
        toInsert
            .add({'game': 'Fresco', 'player': 'Dallas', 'rating': 1, 'v': 1});

        // Avg 3.5 with 4 ratings
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Paul', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Dallas',
          'rating': 4,
          'v': 1
        });
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Anthony',
          'rating': 2,
          'v': 1
        });

        // Avg 4.5 with 4 ratings (counting only highest v)
        toInsert
            .add({'game': 'Dominion', 'player': 'Paul', 'rating': 5, 'v': 2});
        toInsert
            .add({'game': 'Dominion', 'player': 'Erin', 'rating': 4, 'v': 1});
        toInsert
            .add({'game': 'Dominion', 'player': 'Dallas', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Dominion', 'player': 'Anthony', 'rating': 5, 'v': 1});

        // Avg 5 with 2 ratings
        toInsert
            .add({'game': 'Pandemic', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert
            .add({'game': 'Pandemic', 'player': 'Dallas', 'rating': 5, 'v': 1});

        await collection.insertMany(toInsert);

        // Avg player ratings
        // Dallas = 3, Anthony 3.5, Paul = 4, Erin = 4.25
/* We want equivalent of this when used on the mongo shell.
 * (Should be able to just copy and paste below once test is run and failed once)
db.runCommand(
{ aggregate : "testAggregate", pipeline : [
{"$group": {
      "_id": { "game": "$game", "player": "$player" },
      "rating": { "$sum": "$rating" } } },
{"$group": {
        "_id": "$_id.game",
        "avgRating": { "$avg": "$rating" } } },
{ "$sort": { "_id": 1 } }
]});
 */
        var pipeline = <Map<String, Object>>[];
        var p1 = {
          r'$group': {
            '_id': {'game': r'$game', 'player': r'$player'},
            'rating': {r'$sum': r'$rating'}
          }
        };
        var p2 = {
          r'$group': {
            '_id': r'$_id.game',
            'avgRating': {r'$avg': r'$rating'}
          }
        };
        var p3 = {
          r'$sort': {'_id': 1}
        };

        pipeline.add(p1);
        pipeline.add(p2);
        pipeline.add(p3);

        expect(p1['\u0024group'], isNotNull);
        expect(p1['\$group'], isNotNull);

        var aggregateOperation = AggregateOperation(pipeline,
            collection: collection, cursor: {'batchSize': 3});
        var v = await aggregateOperation.execute();
        final cursor = v[keyCursor] as Map;
        expect(cursor['id'], const TypeMatcher<int>());
        final firstBatch = cursor[keyFirstBatch] as List;
        expect(firstBatch.length, 3);
        expect(firstBatch.first[key_Id], 'Age of Steam');
        expect(firstBatch.first['avgRating'], 3);
      });

      test('Aggregate To Stream', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var toInsert = <Map<String, dynamic>>[];

        // Avg 1 with 1 rating
        toInsert.add({
          'game': 'At the Gates of Loyang',
          'player': 'Dallas',
          'rating': 1,
          'v': 1
        });

        // Avg 3 with 1 rating
        toInsert.add(
            {'game': 'Age of Steam', 'player': 'Paul', 'rating': 3, 'v': 1});

        // Avg 2 with 2 ratings
        toInsert.add({'game': 'Fresco', 'player': 'Erin', 'rating': 3, 'v': 1});
        toInsert
            .add({'game': 'Fresco', 'player': 'Dallas', 'rating': 1, 'v': 1});

        // Avg 3.5 with 4 ratings
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Paul', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Dallas',
          'rating': 4,
          'v': 1
        });
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Anthony',
          'rating': 2,
          'v': 1
        });

        // Avg 4.5 with 4 ratings (counting only highest v)
        toInsert
            .add({'game': 'Dominion', 'player': 'Paul', 'rating': 5, 'v': 2});
        toInsert
            .add({'game': 'Dominion', 'player': 'Erin', 'rating': 4, 'v': 1});
        toInsert
            .add({'game': 'Dominion', 'player': 'Dallas', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Dominion', 'player': 'Anthony', 'rating': 5, 'v': 1});

        // Avg 5 with 2 ratings
        toInsert
            .add({'game': 'Pandemic', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert
            .add({'game': 'Pandemic', 'player': 'Dallas', 'rating': 5, 'v': 1});

        await collection.insertMany(toInsert);

        // Avg player ratings
        // Dallas = 3, Anthony 3.5, Paul = 4, Erin = 4.25
/* We want equivalent of this when used on the mongo shell.
 * (Should be able to just copy and paste below once test is run and failed once)
db.runCommand(
{ aggregate : "testAggregate", pipeline : [
{"$group": {
      "_id": { "game": "$game", "player": "$player" },
      "rating": { "$sum": "$rating" } } },
{"$group": {
        "_id": "$_id.game",
        "avgRating": { "$avg": "$rating" } } },
{ "$sort": { "_id": 1 } }
]});
 */
        var pipeline = <Map<String, Object>>[];
        var p1 = {
          r'$group': {
            key_Id: {'game': r'$game', 'player': r'$player'},
            'rating': {r'$sum': r'$rating'}
          }
        };
        var p2 = {
          r'$group': {
            key_Id: r'$_id.game',
            'avgRating': {r'$avg': r'$rating'}
          }
        };
        var p3 = {
          r'$sort': {key_Id: 1}
        };

        pipeline.add(p1);
        pipeline.add(p2);
        pipeline.add(p3);

        expect(p1['\u0024group'], isNotNull);
        expect(p1[r'$group'], isNotNull);
        // set batchSize parameter to split response to 2 chunks
        /*   var aggregate = await collection
            .aggregateToStream(pipeline,
                cursorOptions: {'batchSize': 1}, allowDiskUse: true)
            .toList(); */
        var cursor = ModernCursor(AggregateOperation(pipeline,
            collection: collection, cursor: {'batchSize': 1}));
        var aggregate = await cursor.stream.toList();

        expect(aggregate.isNotEmpty, isTrue);
        expect(aggregate.first[key_Id], 'Age of Steam');
        expect(aggregate.first['avgRating'], 3);
      });
    }, skip: cannotRunTests);

    tearDownAll(() async {
      await db.open();
      await Future.forEach(usedCollectionNames,
          (String collectionName) => db.collection(collectionName).drop());
      await db.close();
    });
  });

  group('Change Stream', () {
    var cannotRunTests = false;
    var isStandalone = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
      if (db.masterConnection != null &&
          db.masterConnection.serverCapabilities.isStandalone) {
        isStandalone = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('Simple change from collection with changeStream', () async {
      var collectionName = getRandomCollectionName();
      /*   var resultMap = await db.createCollection(collectionName,
          createCollectionOptions:
              CreateCollectionOptions(capped: true, size: 5242880, max: 5000));
      expect(resultMap[keyOk], 1.0); */
      var collection = db.collection(collectionName);
      await insertManyDocuments(collection, 3);

      var pipeline =
          AggregationPipelineBuilder() /* .addStage(Group(
          id: 'games',
          fields: {'total': Sum(Field('cost')), 'avg': Avg(Field('cost'))})) */
          ;

      //List<Map<String, Object>> pipeMap = pipeline.build();
      //pipeMap.insert(0, {aggregateChangeStream: {}});
      var cursor =
          ModernCursor(ChangeStreamOperation(pipeline, collection: collection));
      var stream = cursor.changeStream;

      var gotFourth = false;
      var gotFifth = false;

      if (isStandalone) {
        expect(() async {
          await for (var event in stream) {
            print(event.serverResponse['a']);
          }
        }, throwsMongoDartError);
        return;
      }

      var aResult = 3;
      var controller = stream.listen((changeEvent) {
        Map fullDocument = changeEvent.fullDocument;
        expect(fullDocument['a'], aResult++);

        if (fullDocument['a'] == 3) {
          expect(changeEvent.isInsert, isTrue);
          gotFourth = true;
        } else if (fullDocument['a'] == 4) {
          expect(changeEvent.isInsert, isTrue);
          gotFifth = true;
        }
      });

      expect(cursor.state, State.INIT);

      await Future.delayed(Duration(seconds: 2));

      await collection.insertOne({'a': 3});

      await Future.doWhile(() async {
        if (gotFifth) {
          await controller.cancel();
          return false;
        } else if (gotFourth) {
          gotFourth = false;
          controller.pause();
          await collection.insertOne({'a': 4});
        }
        await Future.delayed(Duration(seconds: 1));
        if (controller.isPaused) {
          controller.resume();
        }

        return true;
      });
      expect(cursor.state, State.CLOSED);
    }, skip: cannotRunTests);

    test('Change with match from collection with changeStream', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);
      await insertManyDocuments(collection, 3);

      var pipeline =
          /* <Map<String, Object>>[
        <String, Object>{
          r'$match': {
            'fullDocument.a': {r'$ne': 15}
          }
        }
      ]; */
          AggregationPipelineBuilder()
              .addStage(Match(where.lt('fullDocument.a', 15).map['\$query']));

      var cursor =
          ModernCursor(ChangeStreamOperation(pipeline, collection: collection));
      var stream = cursor.changeStream;

      var gotFourth = false;
      var gotFifth = false;

      if (isStandalone) {
        expect(() async {
          await for (var event in stream) {
            print(event.serverResponse['a']);
          }
        }, throwsMongoDartError);
        return;
      }

      var aResult = 3;
      var controller = stream.listen((changeEvent) {
        Map fullDocument = changeEvent.fullDocument;

        expect(fullDocument['a'], aResult++);

        if (fullDocument['a'] == 3) {
          expect(changeEvent.isInsert, isTrue);
          gotFourth = true;
        } else if (fullDocument['a'] == 4) {
          expect(changeEvent.isInsert, isTrue);
          gotFifth = true;
        }
      });

      expect(cursor.state, State.INIT);

      await Future.delayed(Duration(seconds: 2));

      await collection.insertOne({'a': 3}, writeConcern: WriteConcern.MAJORITY);

      await Future.doWhile(() async {
        if (gotFifth) {
          await controller.cancel();
          return false;
        } else if (gotFourth) {
          gotFourth = false;
          controller.pause();
          await collection.insertOne({'a': 4});
        }
        await Future.delayed(Duration(seconds: 1));
        if (controller.isPaused) {
          controller.resume();
        }

        return true;
      });

      expect(cursor.state, State.CLOSED);
    }, skip: cannotRunTests);

    test('Change with match from collection.watch()', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);
      await insertManyDocuments(collection, 3);

      var pipeline = AggregationPipelineBuilder()
          .addStage(Match(where.lt('fullDocument.a', 15).map['\$query']));

      var stream = collection.watch(pipeline);

      var gotFourth = false;
      var gotFifth = false;

      if (isStandalone) {
        expect(() async {
          await for (var event in stream) {
            print(event.serverResponse['a']);
          }
        }, throwsMongoDartError);
        return;
      }

      var aResult = 3;
      var controller = stream.listen((changeEvent) {
        Map fullDocument = changeEvent.fullDocument;

        expect(fullDocument['a'], aResult++);

        if (fullDocument['a'] == 3) {
          expect(changeEvent.isInsert, isTrue);
          gotFourth = true;
        } else if (fullDocument['a'] == 4) {
          expect(changeEvent.isInsert, isTrue);
          gotFifth = true;
        }
      });

      await Future.delayed(Duration(seconds: 2));

      await collection.insertOne({'a': 3}, writeConcern: WriteConcern.MAJORITY);

      await Future.doWhile(() async {
        if (gotFifth) {
          await controller.cancel();
          return false;
        } else if (gotFourth) {
          gotFourth = false;
          controller.pause();
          await collection.insertOne({'a': 4});
        }
        await Future.delayed(Duration(seconds: 1));
        if (controller.isPaused) {
          controller.resume();
        }

        return true;
      });
    }, skip: cannotRunTests);

    tearDownAll(() async {
      await db.open();
      await Future.forEach(usedCollectionNames,
          (String collectionName) => db.collection(collectionName).drop());
      await db.close();
    });
  });
}
