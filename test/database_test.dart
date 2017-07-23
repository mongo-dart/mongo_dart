library database_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:async';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const dbName = "test-mongo-dart";

const DefaultUri = 'mongodb://localhost:27017/$dbName';

Db db;
Uuid uuid = new Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  String name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

Future testGetCollectionInfos() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insertAll([
    {"a": 1}
  ]);
  var collectionInfos = await db.getCollectionInfos({'name': collectionName});

  expect(collectionInfos, hasLength(1));

  collection.drop();
}

Future testRemove() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insertAll([
    {"a": 1}
  ]);

  var collectionInfos = await db.getCollectionInfos({'name': collectionName});
  expect(collectionInfos, hasLength(1));

  await db.removeFromCollection(collectionName);

  var allCollectionDocuments = await collection.find().toList();
  expect(allCollectionDocuments, isEmpty);
}

Future testDropDatabase() async {
  await db.drop();
}

Future testGetNonce() async {
  var result = await db.getNonce();
  expect(result["ok"], 1);
}

Future getBuildInfo() async {
  var result = await db.getBuildInfo();
  expect(result["ok"], 1);
}

Future testIsMaster() async {
  var result = await db.isMaster();
  expect(result["ok"], 1);
}

testCollectionCreation() {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);
  return collection;
}

Future testEachOnEmptyCollection() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int count = 0;
  int sum = 0;

  await for (var document in collection.find()) {
    sum += document["a"];
    count++;
  }

  expect(sum, 0);
  expect(count, 0);
}

Future testFindEachWithThenClause() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int count = 0;
  int sum = 0;
  await collection.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);

  await for (var document in collection.find()) {
    sum += document["score"];
    count++;
  }

  expect(sum, 13);
  expect(count, 3);
}

Future testDateTime() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insertAll([
    {"day": 1, "posted_on": new DateTime.utc(2013, 1, 1)},
    {"day": 2, "posted_on": new DateTime.utc(2013, 1, 2)},
    {"day": 3, "posted_on": new DateTime.utc(2013, 1, 3)},
    {"day": 4, "posted_on": new DateTime.utc(2013, 1, 4)},
    {"day": 5, "posted_on": new DateTime.utc(2013, 1, 5)},
    {"day": 6, "posted_on": new DateTime.utc(2013, 1, 6)},
    {"day": 7, "posted_on": new DateTime.utc(2013, 1, 7)},
    {"day": 8, "posted_on": new DateTime.utc(2013, 1, 8)},
    {"day": 9, "posted_on": new DateTime.utc(2013, 1, 9)}
  ]);

  var result = await collection
      .find(where.lt('posted_on', new DateTime.utc(2013, 1, 5)))
      .toList();

  expect(result is List, isTrue);
  expect(result.length, 4);
}

testFindEach() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int count = 0;
  int sum = 0;
  await collection.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);

  await for (var document in collection.find()) {
    count++;
    sum += document["score"];
  }

  expect(count, 3);
  expect(sum, 13);
}

Future testFindStream() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int count = 0;
  int sum = 0;
  await collection.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);

  await for (var document in collection.find()) {
    count++;
    sum += document["score"];
  }

  expect(count, 3);
  expect(sum, 13);
}

Future testDrop() async {
  String collectionName = getRandomCollectionName();

  await db.dropCollection(collectionName);
}

Future testSaveWithIntegerId() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [
    {"_id": 1, "name": "a", "value": 10},
    {"_id": 2, "name": "b", "value": 20},
    {"_id": 3, "name": "c", "value": 30},
    {"_id": 4, "name": "d", "value": 40}
  ];

  collection.insertAll(toInsert);
  var result = await collection.findOne({"name": "c"});
  expect(result["value"], 30);

  result = await collection.findOne({"_id": 3});
  result["value"] = 2;
  await collection.save(result);

  result = await collection.findOne({"_id": 3});
  expect(result["value"], 2);

  result = await collection.findOne(where.eq("_id", 3));
  expect(result["value"], 2);

  final notThere = {"_id": 5, "name": "d", "value": 50};
  await collection.save(notThere);
  result = await collection.findOne(where.eq("_id", 5));
  expect(result["value"], 50);
}

Future testSaveWithObjectId() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [
    {"name": "a", "value": 10},
    {"name": "b", "value": 20},
    {"name": "c", "value": 30},
    {"name": "d", "value": 40}
  ];

  await collection.insertAll(toInsert);
  var result = await collection.findOne({"name": "c"});
  expect(result["value"], 30);

  var id = result["_id"];
  result = await collection.findOne({"_id": id});
  expect(result["value"], 30);

  result["value"] = 1;
  await collection.save(result);
  result = await collection.findOne({"_id": id});
  expect(result["value"], 1);
}

Future testInsertWithObjectId() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  var id;
  var objectToSave;
  objectToSave = {"_id": new ObjectId(), "name": "a", "value": 10};
  id = objectToSave["_id"];
  await collection.insert(objectToSave);

  var result = await collection.findOne(where.eq("name", "a"));

  expect(result["_id"], id);
  expect(result["value"], 10);
}

Future testCount() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await insertManyDocuments(collection, 167);

  var result = await collection.count();
  expect(result, 167);
}

Future testDistinct() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insert({"foo": 1});
  await collection.insert({"foo": 2});
  await collection.insert({"foo": 2});
  await collection.insert({"foo": 3});
  await collection.insert({"foo": 3});
  await collection.insert({"foo": 3});
  var result = await collection.distinct("foo");

  List values = result['values'];
  expect(values[0], 1);
  expect(values[1], 2);
  expect(values[2], 3);
}

Future testAggregate() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [];

  // Avg 1 with 1 rating
  toInsert.add({
    "game": "At the Gates of Loyang",
    "player": "Dallas",
    "rating": 1,
    "v": 1
  });

  // Avg 3 with 1 rating
  toInsert.add({"game": "Age of Steam", "player": "Paul", "rating": 3, "v": 1});

  // Avg 2 with 2 ratings
  toInsert.add({"game": "Fresco", "player": "Erin", "rating": 3, "v": 1});
  toInsert.add({"game": "Fresco", "player": "Dallas", "rating": 1, "v": 1});

  // Avg 3.5 with 4 ratings
  toInsert
      .add({"game": "Ticket To Ride", "player": "Paul", "rating": 4, "v": 1});
  toInsert
      .add({"game": "Ticket To Ride", "player": "Erin", "rating": 5, "v": 1});
  toInsert
      .add({"game": "Ticket To Ride", "player": "Dallas", "rating": 4, "v": 1});
  toInsert.add(
      {"game": "Ticket To Ride", "player": "Anthony", "rating": 2, "v": 1});

  // Avg 4.5 with 4 ratings (counting only highest v)
  toInsert.add({"game": "Dominion", "player": "Paul", "rating": 5, "v": 2});
  toInsert.add({"game": "Dominion", "player": "Erin", "rating": 4, "v": 1});
  toInsert.add({"game": "Dominion", "player": "Dallas", "rating": 4, "v": 1});
  toInsert.add({"game": "Dominion", "player": "Anthony", "rating": 5, "v": 1});

  // Avg 5 with 2 ratings
  toInsert.add({"game": "Pandemic", "player": "Erin", "rating": 5, "v": 1});
  toInsert.add({"game": "Pandemic", "player": "Dallas", "rating": 5, "v": 1});

  await collection.insertAll(toInsert);

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
  List pipeline = new List();
  var p1 = {
    "\$group": {
      "_id": {"game": "\$game", "player": "\$player"},
      "rating": {"\$sum": "\$rating"}
    }
  };
  var p2 = {
    "\$group": {
      "_id": "\$_id.game",
      "avgRating": {"\$avg": "\$rating"}
    }
  };
  var p3 = {
    "\$sort": {"_id": 1}
  };

  pipeline.add(p1);
  pipeline.add(p2);
  pipeline.add(p3);

  expect(p1["\u0024group"], isNotNull);
  expect(p1["\$group"], isNotNull);

  var v = await collection.aggregate(pipeline);
  List result = v['result'];
  expect(result[0]["_id"], "Age of Steam");
  expect(result[0]["avgRating"], 3);
}

Future testAggregateToStream() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  bool skipTest = false;
  var buildInfo = await db.getBuildInfo();
  var versionArray = buildInfo['versionArray'];
  var versionNum = versionArray[0] * 100 + versionArray[1];
  if (versionNum < 206) {
    // Skip test for MongoDb server older then version 2.6
    skipTest = true;
    print(
        'testAggregateToStream skipped as server is older then version 2.6: ${buildInfo["version"]}');
    if (skipTest) {
      return;
    }
  }

  List toInsert = [];

  // Avg 1 with 1 rating
  toInsert.add({
    "game": "At the Gates of Loyang",
    "player": "Dallas",
    "rating": 1,
    "v": 1
  });

  // Avg 3 with 1 rating
  toInsert.add({"game": "Age of Steam", "player": "Paul", "rating": 3, "v": 1});

  // Avg 2 with 2 ratings
  toInsert.add({"game": "Fresco", "player": "Erin", "rating": 3, "v": 1});
  toInsert.add({"game": "Fresco", "player": "Dallas", "rating": 1, "v": 1});

  // Avg 3.5 with 4 ratings
  toInsert
      .add({"game": "Ticket To Ride", "player": "Paul", "rating": 4, "v": 1});
  toInsert
      .add({"game": "Ticket To Ride", "player": "Erin", "rating": 5, "v": 1});
  toInsert
      .add({"game": "Ticket To Ride", "player": "Dallas", "rating": 4, "v": 1});
  toInsert.add(
      {"game": "Ticket To Ride", "player": "Anthony", "rating": 2, "v": 1});

  // Avg 4.5 with 4 ratings (counting only highest v)
  toInsert.add({"game": "Dominion", "player": "Paul", "rating": 5, "v": 2});
  toInsert.add({"game": "Dominion", "player": "Erin", "rating": 4, "v": 1});
  toInsert.add({"game": "Dominion", "player": "Dallas", "rating": 4, "v": 1});
  toInsert.add({"game": "Dominion", "player": "Anthony", "rating": 5, "v": 1});

  // Avg 5 with 2 ratings
  toInsert.add({"game": "Pandemic", "player": "Erin", "rating": 5, "v": 1});
  toInsert.add({"game": "Pandemic", "player": "Dallas", "rating": 5, "v": 1});

  await collection.insertAll(toInsert);

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
  List pipeline = new List();
  var p1 = {
    "\$group": {
      "_id": {"game": "\$game", "player": "\$player"},
      "rating": {"\$sum": "\$rating"}
    }
  };
  var p2 = {
    "\$group": {
      "_id": "\$_id.game",
      "avgRating": {"\$avg": "\$rating"}
    }
  };
  var p3 = {
    "\$sort": {"_id": 1}
  };

  pipeline.add(p1);
  pipeline.add(p2);
  pipeline.add(p3);

  expect(p1["\u0024group"], isNotNull);
  expect(p1["\$group"], isNotNull);
  // set batchSize parameter to split response to 2 chunks
  var aggregate = await collection
      .aggregateToStream(pipeline,
          cursorOptions: {'batchSize': 1}, allowDiskUse: true)
      .toList();

  expect(aggregate.isNotEmpty, isTrue);
  expect(aggregate[0]["_id"], "Age of Steam");
  expect(aggregate[0]["avgRating"], 3);
}

Future testSkip() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await insertManyDocuments(collection, 600);

  var result = await collection.findOne(where.sortBy('a').skip(300));

  expect(result["a"], 300);
}

Future testUpdateWithUpsert() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  var result = await collection.insert({'name': 'a', 'value': 10});
  expect(result['n'], 0);

  var results = await collection.find({'name': 'a'}).toList();
  expect(results.length, 1);
  expect(results.first['name'], 'a');
  expect(results.first['value'], 10);

  var objectUpdate = {
    r'$set': {'value': 20}
  };
  result = await collection.update({'name': 'a'}, objectUpdate);
  expect(result['updatedExisting'], true);
  expect(result['n'], 1);

  results = await collection.find({'name': 'a'}).toList();
  expect(results.length, 1);
  expect(results.first['value'], 20);
}

Future testUpdateWithMultiUpdate() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  var result = await collection.insertAll([
    {'key': 'a', 'value': 'initial_value1'},
    {'key': 'a', 'value': 'initial_value2'},
    {'key': 'b', 'value': 'initial_value_b'}
  ]);
  expect(result['n'], 0);

  var results = await collection.find({'key': 'a'}).toList();
  expect(results.length, 2);
  expect(results.first['key'], 'a');
  expect(results.first['value'], 'initial_value1');

  result = await collection.update(where.eq('key', 'a'),
      modify.set('value', 'value_modified_for_only_one_with_default'));
  expect(result['updatedExisting'], true);
  expect(result['n'], 1);

  results = await collection
      .find({'value': 'value_modified_for_only_one_with_default'}).toList();
  expect(results.length, 1);

  result = await collection.update(where.eq('key', 'a'),
      modify.set('value', 'value_modified_for_only_one_with_multiupdate_false'),
      multiUpdate: false);
  expect(result['updatedExisting'], true);
  expect(result['n'], 1);

  results = await collection.find(
      {'value': 'value_modified_for_only_one_with_multiupdate_false'}).toList();
  expect(results.length, 1);

  result = await collection.update(
      where.eq('key', 'a'), modify.set('value', 'new_value'),
      multiUpdate: true);
  expect(result['updatedExisting'], true);
  expect(result['n'], 2);

  results = await collection.find({'value': 'new_value'}).toList();
  expect(results.length, 2);

  results = await collection.find({'key': 'b'}).toList();
  expect(results.length, 1);
  expect(results.first['value'], 'initial_value_b');
}

Future testLimitWithSortByAndSkip() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int counter = 0;
  Cursor cursor;

  await insertManyDocuments(collection, 1000);

  cursor = collection.createCursor(where.sortBy('a').skip(300).limit(10));

  counter = await cursor.stream.length;
  expect(counter, 10);
  expect(cursor.state, State.CLOSED);
  expect(cursor.cursorId, 0);
}

Future insertManyDocuments(DbCollection collection, int numberOfRecords) async {
  List toInsert = [];
  for (int n = 0; n < numberOfRecords; n++) {
    toInsert.add({"a": n});
  }

  await collection.insertAll(toInsert);
}

Future testLimit() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int counter = 0;
  Cursor cursor;
  await insertManyDocuments(collection, 30000);

  cursor = collection.createCursor(where.limit(10));

  await cursor.stream.forEach((e) => counter++);
  expect(counter, 10);
  expect(cursor.state, State.CLOSED);
  expect(cursor.cursorId, 0);
}

testCursorCreation() {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  Cursor cursor = new Cursor(db, collection, null);
  return cursor;
}

Future testPingRaw() async {
  DbCollection collection = db.collection('\$cmd');
  Cursor cursor = new Cursor(db, collection, where.eq('ping', 1).limit(1));
  MongoQueryMessage queryMessage = cursor.generateQueryMessage();

  var result = await db.queryMessage(queryMessage);

  expect(result.documents[0], containsPair('ok', 1));
}

Future testNextObject() async {
  DbCollection collection = db.collection('\$cmd');
  Cursor cursor = new Cursor(db, collection, where.eq('ping', 1).limit(1));

  var newCursor = await cursor.nextObject();

  expect(newCursor, containsPair('ok', 1));
}

Future testNextObjectToEnd() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  Cursor cursor;
  await collection.insert({"a": 1});
  await collection.insert({"a": 2});
  await collection.insert({"a": 3});

  cursor = new Cursor(db, collection, where.limit(10));
  var result = await cursor.nextObject();
  expect(result, isNotNull);

  result = await cursor.nextObject();
  expect(result, isNotNull);

  result = await cursor.nextObject();
  expect(result, isNotNull);

  result = await cursor.nextObject();
  expect(result, isNull);
}

Future testCursorWithOpenServerCursor() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await insertManyDocuments(collection, 1000);
  var cursor = new Cursor(db, collection, where.limit(10));

  await cursor.nextObject();

  expect(cursor.state, State.OPEN);
  expect(cursor.cursorId, isPositive);
}

Future testCursorGetMore() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  int count = 0;
  Cursor cursor = new Cursor(db, collection, where.limit(10));
  count = await cursor.stream.length;
  expect(count, 0);

  await insertManyDocuments(collection, 1000);

  cursor = new Cursor(db, collection, null);
  count = await cursor.stream.length;

  expect(count, 1000);
  expect(cursor.cursorId, 0);
  expect(cursor.state, State.CLOSED);
}

Future testCursorClosing() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await insertManyDocuments(collection, 10000);

  var cursor = collection.createCursor();
  expect(cursor.state, State.INIT);

  var newCursor = await cursor.nextObject();
  expect(cursor.state, State.OPEN);
  expect(cursor.cursorId, isPositive);

  await cursor.close();
  expect(cursor.state, State.CLOSED);
  expect(cursor.cursorId, 0);

  var result = await collection.findOne();
  expect(newCursor, isNotNull);
  // TODO: I think there was an error in the original test
  // I believe it should be expect(result, isNotNull)
  // But this seems to be the original behaviour of the test
  expect(result, isNotNull); // Added this -- and it passes!
}

void testDbCommandCreation() {
  String collectionName = getRandomCollectionName();

  DbCommand dbCommand = new DbCommand(db, collectionName, 0, 0, 1, {}, {});
  expect(dbCommand.collectionNameBson.value, '$dbName.$collectionName');
}

Future testPingDbCommand() async {
  DbCommand pingCommand = DbCommand.createPingCommand(db);

  var result = await db.queryMessage(pingCommand);

  expect(result.documents[0], containsPair('ok', 1));
}

Future testDropDbCommand() async {
  DbCommand command = DbCommand.createDropDatabaseCommand(db);

  var result = await db.queryMessage(command);

  expect(result.documents[0]["ok"], 1);
}

Future testIsMasterDbCommand() async {
  DbCommand isMasterCommand = DbCommand.createIsMasterCommand(db);

  var result = await db.queryMessage(isMasterCommand);

  expect(result.documents[0], containsPair('ok', 1));
}

String _md5(String value) => crypto.md5.convert(value.codeUnits).toString();
testAuthComponents() {
  expect(_md5(''), 'd41d8cd98f00b204e9800998ecf8427e');
  expect(_md5('md4'), 'c93d3bf7a7c4afe94b64e30c2ce39f4f');
  expect(_md5('md5'), '1bc29b36f623ba82aaf6724fd3b16718');
  var nonce = '94505e7196beb570';
  var userName = 'dart';
  var password = 'test';
  var test_key = 'aea09fb38775830306c5ff6de964ff04';
  var hashed_password = _md5('${userName}:mongo:${password}');
  var key = _md5('${nonce}${userName}${hashed_password}');
  expect(key, test_key);
}

Future testAuthenticationWithUri() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insert({"a": 1});
  await collection.insert({"a": 2});
  await collection.insert({"a": 3});

  var foundValue = await collection.findOne();

  expect(foundValue['a'], isNotNull);
}

Future testGetIndexes() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await insertManyDocuments(collection, 100);

  var indexes = await collection.getIndexes();

  expect(indexes.length, 1);
}

Future testIndexCreation() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [];
  for (int n = 0; n < 6; n++) {
    toInsert.add({
      'a': n,
      'embedded': {'b': n, 'c': n * 10}
    });
  }
  await collection.insertAll(toInsert);

  var res = await db.createIndex(collectionName, key: 'a');
  expect(res['ok'], 1.0);

  res = await db.createIndex(collectionName, keys: {'a': -1, 'embedded.c': 1});
  expect(res['ok'], 1.0);

  res = await db.createIndex(collectionName, keys: {
    'a': -1
  }, partialFilterExpression: {
    "embedded.c": {r"$exists": true}
  });
  expect(res['ok'], 1.0);

  var indexes = await collection.getIndexes();
  expect(indexes.length, 4);

  res = await db.ensureIndex(collectionName, keys: {'a': -1, 'embedded.c': 1});
  expect(res['ok'], 1.0);
}

Future testEnsureIndexWithIndexCreation() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [];
  for (int n = 0; n < 6; n++) {
    toInsert.add({
      'a': n,
      'embedded': {'b': n, 'c': n * 10}
    });
  }

  await collection.insertAll(toInsert);

  var result =
      await db.ensureIndex(collectionName, keys: {'a': -1, 'embedded.c': 1});
  expect(result['ok'], 1.0);
  expect(result['err'], isNull);
}

Future testIndexCreationErrorHandling() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [];
  for (int n = 0; n < 6; n++) {
    toInsert.add({'a': n});
  }
  // Insert duplicate
  toInsert.add({'a': 3});

  await collection.insertAll(toInsert);

  try {
    await db.ensureIndex(collectionName, key: 'a', unique: true);
    fail("Expecting an error, but wasn't thrown");
  } catch (e) {
    expect(e['err'],
        predicate((String msg) => msg.contains("duplicate key error")));
  }
}

Future testSafeModeUpdate() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  for (int n = 0; n < 6; n++) {
    await collection.insert({
      'a': n,
      'embedded': {'b': n, 'c': n * 10}
    });
  }

  var result = await collection.update({'a': 200}, {'a': 100});
  expect(result['updatedExisting'], false);
  expect(result['n'], 0);

  result = await collection.update({'a': 3}, {'a': 100});
  expect(result['updatedExisting'], true);
  expect(result['n'], 1);
}

Future testFindWithFieldsClause() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);

  var result =
      await collection.findOne(where.eq('name', 'Vadim').fields(['score']));

  expect(result['name'], isNull);
  expect(result['score'], 4);
}

Future testFindAndModify() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);
  var result;

  await collection.insertAll([
    {"name": "Bob", "score": 2},
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5},
    {"name": "Alice", "score": 1},
  ]);

  result = await collection.findAndModify(
      query: where.eq('name', 'Vadim'),
      update: modify.inc('score', 10),
      fields: where.fields(['score']).excludeFields(['_id']));
  expect(result['_id'], isNull);
  expect(result['name'], isNull);
  expect(result['score'], 4);

  result = await collection.findAndModify(
      query: where.eq('name', 'Daniil'),
      returnNew: true,
      update: modify.inc('score', 3));
  expect(result['_id'], isNotNull);
  expect(result['name'], 'Daniil');
  expect(result['score'], 7);

  result = await collection.findAndModify(
      query: where.eq('name', 'Nick'), remove: true);
  expect(result['_id'], isNotNull);
  expect(result['name'], 'Nick');
  expect(result['score'], 5);

  result = await collection.findAndModify(
      query: where.eq('name', 'Unknown'), update: modify.inc('score', 3));
  expect(result, isNull);

  result = await collection.findAndModify(
      query: where.eq('name', 'Unknown'),
      returnNew: true,
      update: modify.inc('score', 3));
  expect(result, isNull);

  result = await collection.findAndModify(
      sort: where.sortBy('score'),
      returnNew: true,
      update: modify.inc('score', 100));
  expect(result['name'], 'Alice');
  expect(result['score'], 101);

  result = await collection.findAndModify(
      query: where.eq('name', 'New Comer'),
      returnNew: true,
      upsert: true,
      update: modify.inc('score', 100));
  expect(result['name'], 'New Comer');
  expect(result['score'], 100);
}

Future testSimpleQuery() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  ObjectId id;
  List toInsert = [];
  for (var n = 0; n < 10; n++) {
    toInsert.add({"my_field": n, "str_field": "str_$n"});
  }
  await collection.insertAll(toInsert);

  var result = await collection
      .find(where.gt("my_field", 5).sortBy('my_field'))
      .toList();
  expect(result.length, 4);
  expect(result[0]['my_field'], 6);

  var result1 = await collection.findOne(where.eq('my_field', 3));
  expect(result1, isNotNull);
  expect(result1['my_field'], 3);
  id = result1['_id'];

  var result2 = await collection.findOne(where.id(id));
  expect(result2, isNotNull);
  expect(result2['my_field'], 3);

  collection.remove(where.id(id));
  var result3 = await collection.findOne(where.eq('my_field', 3));
  expect(result3, isNull);
}

Future testCompoundQuery() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  List toInsert = [];
  for (var n = 0; n < 10; n++) {
    toInsert.add({"my_field": n, "str_field": "str_$n"});
  }

  await collection.insertAll(toInsert);

  var result = await collection
      .find(where.gt("my_field", 8).or(where.lt('my_field', 2)))
      .toList();
  expect(result.length, 3);

  var result1 = await collection.findOne(where
      .gt("my_field", 8)
      .or(where.lt('my_field', 2))
      .and(where.eq('str_field', 'str_1')));
  expect(result1, isNotNull);
  expect(result1['my_field'], 1);
}

Future testFieldLevelUpdateSimple() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  ObjectId id;
  var result = await collection.insert({'name': 'a', 'value': 10});
  expect(result['n'], 0);

  result = await collection.findOne({'name': 'a'});
  expect(result, isNotNull);

  id = result['_id'];
  result = await collection.update(where.id(id), modify.set('name', 'BBB'));
  expect(result['updatedExisting'], true);
  expect(result['n'], 1);

  result = await collection.findOne(where.id(id));
  expect(result, isNotNull);
  expect(result['name'], 'BBB');
}

Future testQueryOnClosedConnection() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await db.close();
  expect(
      collection.find().toList(),
      throwsA((MongoDartError e) =>
          e.message == 'Db is in the wrong state: State.CLOSED'));
}

Future testUpdateOnClosedConnection() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await db.close();
  expect(
      collection.save({"test": "test"}),
      throwsA(
          (MongoDartError e) => e.message == "DB is not open. State.CLOSED"));
}

Future testReopeningDb() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await collection.insert({'one': 'test'});
  await db.close();
  await db.open();

  var result = await collection.findOne();

  expect(result, isNotNull);
}

Future testDbNotOpen() async {
  String collectionName = getRandomCollectionName();
  var collection = db.collection(collectionName);

  await db.close();
  expect(
      collection.findOne(),
      throwsA((MongoDartError e) =>
          e.message == "Db is in the wrong state: State.CLOSED"));
}

Future testDbOpenWhileStateIsOpening() {
  String collectionName = getRandomCollectionName();

  Db db = new Db(DefaultUri);
  return new Future.sync(() {
    db.open().then((_) {
      return db.collection(collectionName).findOne();
    }).then((res) {
      expect(res, isNull);
      db.close();
    });
    db.open().then((_) {
      return db.collection(collectionName).findOne();
    }).then((res) {
      expect(res, isNull);
    }).catchError((e) {
      expect(e is MongoDartError, isTrue);
      expect(db.state == State.OPENING, isTrue);
    });
  });
}

testInvalidIndexCreationErrorHandling() {
  /*
   TODO: Verify why this is supposed to be an invalid index because this
   currently doesn't fail
    */
  String collectionName = getRandomCollectionName();

  expect(db.createIndex(collectionName, key: 'a'),
      throwsA((e) => e is ArgumentError));
}

testInvalidIndexCreationErrorHandling1() {
  String collectionName = getRandomCollectionName();

  expect(db.createIndex(collectionName, key: 'a', keys: {'a': -1}),
      throwsA((e) => e is ArgumentError));
}

Future testFindOneWhileStateIsOpening() {
  String collectionName = getRandomCollectionName();

  Db db = new Db(DefaultUri);
  return new Future.sync(() {
    db.open().then((_) {
      return db.collection(collectionName).findOne();
    }).then((res) {
      expect(res, isNull);
      db.close();
    });

    db.collection(collectionName).findOne().then((res) {
      expect(res, isNull);
    }).catchError((e) {
      expect(e is MongoDartError, isTrue);
      expect(db.state == State.OPENING, isTrue);
    });
  });
}

main() {
  Future initializeDatabase() async {
    db = new Db(DefaultUri);
    await db.open();
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  group("A", () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('DbCollection tests:', () {
      test('testAuthComponents', testAuthComponents);
    });
    group('DBCommand:', () {
      test('testAuthenticationWithUri', testAuthenticationWithUri);
      test('testDropDatabase', testDropDatabase,
          skip: 'this might prevent the tests to pass');
      test('testGetCollectionInfos', testGetCollectionInfos);
      test('testRemove', testRemove);
      test('testGetNonce', testGetNonce);
      test('getBuildInfo', getBuildInfo);
      test('testIsMaster', testIsMaster);
    });

    group('DbCollection tests:', () {
      test('testCollectionCreation', testCollectionCreation);
      test('testLimitWithSortByAndSkip', testLimitWithSortByAndSkip);
      test('testLimitWithSkip', testLimit);
      test('testFindEachWithThenClause', testFindEachWithThenClause);
      test('testSimpleQuery', testSimpleQuery);
      test('testCompoundQuery', testCompoundQuery);
      test('testCount', testCount);
      test('testDistinct', testDistinct);
      test('testFindEach', testFindEach);
      test('testEach', testEachOnEmptyCollection);
      test('testDrop', testDrop);
      test('testSaveWithIntegerId', testSaveWithIntegerId);
      test('testSaveWithObjectId', testSaveWithObjectId);
      test('testInsertWithObjectId', testInsertWithObjectId);
      test('testSkip', testSkip);
      test('testDateTime', testDateTime);
      test('testUpdateWithUpsert', testUpdateWithUpsert);
      test('testUpdateWithMultiUpdate', testUpdateWithMultiUpdate);
      test('testFindWithFieldsClause', testFindWithFieldsClause);
      test('testFindAndModify', testFindAndModify);
    });

    group('Cursor tests:', () {
      test('testCursorCreation', testCursorCreation);
      test('testCursorClosing', testCursorClosing);
      test('testNextObjectToEnd', testNextObjectToEnd);
      test('testPingRaw', testPingRaw);
      test('testNextObject', testNextObject);
      test('testCursorWithOpenServerCursor', testCursorWithOpenServerCursor);
      test('testCursorGetMore', testCursorGetMore);
      test('testFindStream', testFindStream);
    });

    group('DBCommand tests:', () {
      test('testDbCommandCreation', testDbCommandCreation);
      test('testPingDbCommand', testPingDbCommand);
      test('testDropDbCommand', testDropDbCommand);
      test('testIsMasterDbCommand', testIsMasterDbCommand);
    });

    group('Safe mode tests:', () {
      test('testSafeModeUpdate', testSafeModeUpdate);
    });

    group('Indexes tests:', () {
      test('testGetIndexes', testGetIndexes);
      test('testIndexCreation', testIndexCreation);
      test(
          'testEnsureIndexWithIndexCreation', testEnsureIndexWithIndexCreation);
      test('testIndexCreationErrorHandling', testIndexCreationErrorHandling);
    });

    group('Field level update tests:', () {
      test('testFieldLevelUpdateSimple', testFieldLevelUpdateSimple);
    });

    group('Aggregate:', () {
      test('testAggregate', testAggregate);
      test(
          'testAggregateToStream - if server older then version 2.6 test would be skipped',
          testAggregateToStream);
    });
  });

  group("Error handling without opening connection before", () {
    test('testDbOpenWhileStateIsOpening', testDbOpenWhileStateIsOpening);
    test('testFindOneWhileStateIsOpening', testFindOneWhileStateIsOpening);
  });

  group('Error handling:', () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      try {
        await db.open();
      } catch (e) {
        // db possibly already open
      }

      try {
        await db.close();
      } catch (e) {
        // db possibly already closed
      }
    });

    test('testQueryOnClosedConnection', testQueryOnClosedConnection);
    test("testUpdateOnClosedConnection", testUpdateOnClosedConnection);
    test('testReopeningDb', testReopeningDb);
    test('testDbNotOpen', testDbNotOpen);
    test('testInvalidIndexCreationErrorHandling',
        testInvalidIndexCreationErrorHandling,
        skip:
            'It seems to be perfectly valid code. No source for expected exception. TODO remeber how this test was created in the first plave');
    test('testInvalidIndexCreationErrorHandling1',
        testInvalidIndexCreationErrorHandling1);
  });

  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
