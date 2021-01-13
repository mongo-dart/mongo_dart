import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/get_parameter_command/get_parameter_command.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/kill_cursors_command/kill_cursors_command.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/get_all_parameters_command/get_all_parameters_command.dart';

import 'package:mongo_dart/src/database/operation/commands/diagnostic_commands/server_status_command/server_status_command.dart';
import 'package:mongo_dart/src/database/operation/commands/diagnostic_commands/server_status_command/server_status_options.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/get_more_command/get_more_command.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/get_more_command/get_more_options.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
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

  group('Commands', () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Administration Commands', () {
      group('Kill cursor Command:', () {
        test('test on existing cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          await insertManyDocuments(collection, 10000);

          var cursor = await ModernCursor(FindOperation(collection));

          expect(cursor.state, State.INIT);

          var cursorResult = await cursor.nextObject();
          expect(cursor.state, State.OPEN);
          expect(cursor.cursorId.value, isPositive);
          expect(cursorResult['a'], 0);
          expect(cursorResult, isNotNull);
          var command = KillCursorsCommand(collection, [cursor.cursorId]);
          var result = await command.execute();
          expect(result, isNotNull);
          expect(
              (result[keyCursorsKilled] as List).first, cursor.cursorId.value);
          expect(result[keyCursorsAlive], isEmpty);
          expect(result[keyCursorsUnknown], isEmpty);
          expect(result[keyCursorsNotFound], isEmpty);
        });
        test('test on small cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);
          var command = KillCursorsCommand(collection, [BsonLong(1)]);
          var result = await command.execute();
          expect(result, isNotNull);
          expect(result[keyOk], 1.0);
          expect((result[keyCursorsNotFound] as List).first, 1);
          expect(result[keyCursorsAlive], isEmpty);
          expect(result[keyCursorsUnknown], isEmpty);
          expect(result[keyCursorsKilled], isEmpty);
        });
        test('test on non existing cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);
          var command =
              KillCursorsCommand(collection, [BsonLong(111111111111)]);
          var result = await command.execute();
          expect(result, isNotNull);
          expect(result[keyOk], 1.0);
          expect((result[keyCursorsNotFound] as List).first, 111111111111);
          expect(result[keyCursorsAlive], isEmpty);
          expect(result[keyCursorsUnknown], isEmpty);
          expect(result[keyCursorsKilled], isEmpty);
        });
        // The idea is to check if an existing cursor is listend
        // in 'cursorsAlive' element.
        // At present is not listed
        test('test on diff cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);
          await insertManyDocuments(collection, 10000);
          var cursor = await ModernCursor(FindOperation(collection));
          expect(cursor.state, State.INIT);
          await cursor.nextObject();
          var command = KillCursorsCommand(collection, [BsonLong(1)]);
          var result = await command.execute();
          expect(result, isNotNull);
          expect(result[keyOk], 1.0);
          expect((result[keyCursorsNotFound] as List).first, 1);
          expect(result[keyCursorsAlive], isEmpty);
          expect(result[keyCursorsUnknown], isEmpty);
          expect(result[keyCursorsKilled], isEmpty);
        });

        test('test with return Object on small cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);
          var command = KillCursorsCommand(collection, [BsonLong(1)]);
          var result = await command.executeDocument();
          expect(result, isNotNull);
          expect(result.success, isTrue);
          expect(result.cursorsNotFound.first, 1);
          expect(result.cursorsAlive, isNull);
          expect(result.cursorsUnknown, isNull);
          expect(result.cursorsKilled, isNull);
        });
        test('test with return Object on non existing cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);
          var command = KillCursorsCommand(collection, [BsonLong(-1)]);
          var result = await command.executeDocument();
          expect(result, isNotNull);
          expect(result.success, isTrue);
          expect(result.cursorsNotFound.first, -1);
          expect(result.cursorsAlive, isNull);
          expect(result.cursorsUnknown, isNull);
          expect(result.cursorsKilled, isNull);
        });
      });
      group('get more Command:', () {
        test('test on existing cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          await insertManyDocuments(collection, 10000);

          var cursor = await ModernCursor(FindOperation(collection));

          expect(cursor.state, State.INIT);

          var cursorResult = await cursor.nextObject();
          expect(cursor.state, State.OPEN);
          expect(cursor.cursorId.value, isPositive);
          expect(cursorResult['a'], 0);
          expect(cursorResult, isNotNull);
          var command = GetMoreCommand(collection, cursor.cursorId);
          var result = await command.execute();
          expect(result, isNotNull);
          expect(result[keyCursor], isNotNull);

          Map cursorMap = result[keyCursor];
          expect(cursorMap[keyFirstBatch], isNull);
          expect(cursorMap[keyNextBatch], isNotEmpty);
          expect(cursorMap[keyNextBatch].length, 101);
        });
        test('test on non existing cursor', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var command = GetMoreCommand(collection, BsonLong(1));
          var result = await command.execute();
          expect(result, isNotNull);
          expect(result[keyOk], 0.0);
          expect(result[keyCursor], isNull);
          expect((result[keyErrmsg] as String).isNotEmpty, isTrue);
        });
        test('test batch size option', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          await insertManyDocuments(collection, 10000);

          var cursor = await ModernCursor(FindOperation(collection));

          expect(cursor.state, State.INIT);

          var cursorResult = await cursor.nextObject();
          expect(cursor.state, State.OPEN);
          expect(cursor.cursorId.value, isPositive);
          expect(cursorResult['a'], 0);
          expect(cursorResult, isNotNull);
          var options = GetMoreOptions(batchSize: 10);
          var command = GetMoreCommand(collection, cursor.cursorId,
              getMoreOptions: options);
          var result = await command.executeDocument();
          expect(result, isNotNull);
          var cursorRes = result.cursor;
          expect(cursorRes, isNotNull);
          expect(cursorRes.nextBatch, isNotEmpty);
          expect(cursorRes.nextBatch.length, 10);

          options = GetMoreOptions(batchSize: 200);
          command = GetMoreCommand(collection, cursor.cursorId,
              getMoreOptions: options);
          result = await command.executeDocument();
          expect(result, isNotNull);
          cursorRes = result.cursor;
          expect(cursorRes, isNotNull);
          expect(cursorRes.nextBatch.length, 200);
        });
        test('test huge batch size', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          await insertManyDocuments(collection, 10000);

          var cursor = await ModernCursor(FindOperation(collection,
              findOptions: FindOptions(batchSize: 1)));
          await cursor.nextObject();
          var options = GetMoreOptions(batchSize: 10001);
          var command = GetMoreCommand(collection, cursor.cursorId,
              getMoreOptions: options);
          var result = await command.executeDocument();
          expect(result, isNotNull);
          var cursorRes = result.cursor;
          expect(cursorRes, isNotNull);
          expect(cursorRes.nextBatch, isNotEmpty);
          expect(cursorRes.nextBatch.length, 9999);
        });
        test('test error', () async {
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          await insertManyDocuments(collection, 10000);

          var cursor = await ModernCursor(FindOperation(collection));
          await cursor.nextObject();

          var command = GetMoreCommand(collection, cursor.cursorId);
          var result = await command.executeDocument();
          expect(result, isNotNull);
          var cursorRes = result.cursor;
          expect(cursorRes.nextBatch, isNotEmpty);
          expect(cursorRes.nextBatch.length, 101);
          expect(() => GetMoreOptions(batchSize: 0), throwsMongoDartError);
        });
      });

      group('Get All Parameters', () {
        test('Run command', () async {
          var command = GetAllParametersCommand(db);
          var ret = await command.execute();
          expect(ret[keyOk], 1.0);
          expect(ret[keyLogLevel], 0);
          if (!db.masterConnection.serverCapabilities.isShardedCluster) {
            expect(ret[keyFeatureCompatibilityVersion], isMap);
          }
        });
      });
      group('Get Parameter', () {
        test('Run command', () async {
          var command = GetParameterCommand(db, keyLogLevel);
          var ret = await command.execute();
          expect(ret[keyOk], 1.0);
          expect(ret[keyLogLevel], 0);
        });
      });
    });
    group('Diagnostic Commands', () {
      group('Server Status', () {
        test('Map return', () async {
          var command = ServerStatusCommand(db);
          var ret = await command.execute();
          expect(ret, isNotNull);
          expect(ret[keyHost], isNotEmpty);
          expect(ret[keyVersion], isNotEmpty);
          expect(ret[keyLatchAnalysis], isNull);
        });
        test('No Host in RawOptions', () async {
          var command = ServerStatusCommand(db, rawOptions: {
            keyHost: 0,
            keyPid: 0,
            keyAsserts: 0,
          });
          var ret = await command.execute();
          expect(ret, isNotNull);
          expect(ret[keyHost], isNotNull);
          expect(ret[keyPid], isNotNull);
          expect(ret[keyAsserts], isNull);
        });

        test('No Metric in ServerStatusOptions', () async {
          var command = ServerStatusCommand(db,
              serverStatusOptions: ServerStatusOptions(metricsExcluded: true));
          var ret = await command.execute();
          expect(ret, isNotNull);
          expect(ret[keyMetrics], isNull);
        });

        test('No Metric in RawOptions', () async {
          var command = ServerStatusCommand(db, rawOptions: {keyMetrics: 0});
          var ret = await command.execute();
          expect(ret, isNotNull);
          expect(ret[keyMetrics], isNull);
        });

        test('Only instance values', () async {
          var command = ServerStatusCommand(db,
              serverStatusOptions: ServerStatusOptions.instance);
          var ret = await command.execute();
          expect(ret, isNotNull);
          expect(ret[keyMetrics], isNull);
        });

        test('Document return', () async {
          var command = ServerStatusCommand(db);
          var ret = await command.executeDocument();
          expect(ret, isNotNull);
          expect(ret.host, isNotEmpty);
          expect(ret.localTime.isAfter(DateTime(2020)), isTrue);
          expect(ret.version, isNotNull);
        });

        test('No Metric in ServerStatusOptions -> Result class', () async {
          var command = ServerStatusCommand(db,
              serverStatusOptions: ServerStatusOptions(metricsExcluded: true));
          var ret = await command.executeDocument();
          expect(ret, isNotNull);
          expect(ret.metrics, isNull);
        });

        test('No Metric in RawOptions -> Result class', () async {
          var command = ServerStatusCommand(db, rawOptions: {keyMetrics: 0});
          var ret = await command.executeDocument();
          expect(ret, isNotNull);
          expect(ret.metrics, isNull);
        });
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
