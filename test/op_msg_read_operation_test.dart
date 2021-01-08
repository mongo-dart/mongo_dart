@Timeout(Duration(seconds: 300))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/wrapper/create_collection/create_collection_options.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_options.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/get_more_command/get_more_command.dart';
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

  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
