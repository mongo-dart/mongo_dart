library database_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'package:test/test.dart';

const DefaultUri = 'mongodb://127.0.0.1:27017/';
const String collectionName = 'collectionName';

Db db;
DbCollection collection;

Future testGetCollectionInfos() async {
  await collection.insertAll([
    {"a": 1}
  ]);

  var collectionInfos = await db.getCollectionInfos({'name': collectionName});

  expect(collectionInfos, hasLength(1));
}

Future testRemove() async {
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
  Db db = new Db('${DefaultUri}db');
  DbCollection collection = db.collection('student');
  return collection;
}

Future testEachOnEmptyCollection() async {
  int count = 0;
  int sum = 0;

  await collection.find().forEach((document) {
    sum += document["a"];
    count++;
  });

  expect(sum, 0);
  expect(count, 0);
}

Future testFindEachWithThenClause() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int count = 0;
  int sum = 0;
  DbCollection students;
  return db.open().then((c) {
    students = db.collection('students');
    return students.drop();
  }).then((c) {
    students.insertAll([
      {"name": "Vadim", "score": 4},
      {"name": "Daniil", "score": 4},
      {"name": "Nick", "score": 5}
    ]);
    return students.find().forEach((v) {
      sum += v["score"];
      count++;
    });
  }).then((v) {
    expect(sum, 13);
    expect(count, 3);
    return db.close();
  });
}

Future testDateTime() async {
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
  int count = 0;
  int sum = 0;
  await collection.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);

  await collection.find().forEach((document) {
    count++;
    sum += document["score"];
  });

  expect(count, 3);
  expect(sum, 13);
}

Future testFindStream() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int count = 0;
  int sum = 0;
  return db.open().then((c) {
    DbCollection students = db.collection('students');
    students.remove();
    students.insertAll([
      {"name": "Vadim", "score": 4},
      {"name": "Daniil", "score": 4},
      {"name": "Nick", "score": 5}
    ]);
    return students.find().forEach((v1) {
      count++;
      sum += v1["score"];
    });
  }).then((v) {
    expect(count, 3);
    expect(sum, 13);
    return db.close();
  });
}

Future testDrop() async {
  await db.dropCollection(collectionName);
}

Future testSaveWithIntegerId() async {
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
  for (int n = 0; n < 167; n++) {
    await collection.insert({"a": n});
  }
  var result = await collection.count();
  expect(result, 167);
}

Future testDistinct() async {
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

Future testAggregate() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    DbCollection coll = db.collection('testAggregate');
    coll.remove();

    // Avg 1 with 1 rating
    coll.insert({
      "game": "At the Gates of Loyang",
      "player": "Dallas",
      "rating": 1,
      "v": 1
    });

    // Avg 3 with 1 rating
    coll.insert(
        {"game": "Age of Steam", "player": "Paul", "rating": 3, "v": 1});

    // Avg 2 with 2 ratings
    coll.insert({"game": "Fresco", "player": "Erin", "rating": 3, "v": 1});
    coll.insert({"game": "Fresco", "player": "Dallas", "rating": 1, "v": 1});

    // Avg 3.5 with 4 ratings
    coll.insert(
        {"game": "Ticket To Ride", "player": "Paul", "rating": 4, "v": 1});
    coll.insert(
        {"game": "Ticket To Ride", "player": "Erin", "rating": 5, "v": 1});
    coll.insert(
        {"game": "Ticket To Ride", "player": "Dallas", "rating": 4, "v": 1});
    coll.insert(
        {"game": "Ticket To Ride", "player": "Anthony", "rating": 2, "v": 1});

    // Avg 4.5 with 4 ratings (counting only highest v)
    coll.insert({"game": "Dominion", "player": "Paul", "rating": 5, "v": 2});
    coll.insert({"game": "Dominion", "player": "Erin", "rating": 4, "v": 1});
    coll.insert({"game": "Dominion", "player": "Dallas", "rating": 4, "v": 1});
    coll.insert({"game": "Dominion", "player": "Anthony", "rating": 5, "v": 1});

    // Avg 5 with 2 ratings
    coll.insert({"game": "Pandemic", "player": "Erin", "rating": 5, "v": 1});
    coll.insert({"game": "Pandemic", "player": "Dallas", "rating": 5, "v": 1});

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

    return coll.aggregate(pipeline);
  }).then((v) {
    List result = v['result'];
    expect(result[0]["_id"], "Age of Steam");
    expect(result[0]["avgRating"], 3);
    return db.close();
  });
}

Future testAggregateToStream() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  bool skipTest = false;
  return db.open().then((c) {
    return db.getBuildInfo();
  }).then((v) {
    var versionArray = v['versionArray'];
    var versionNum = versionArray[0] * 100 + versionArray[1];
    if (versionNum < 206) {
      // Skip test for MongoDb server older then version 2.6
      skipTest = true;
      print(
          'testAggregateToStream skipped as server is older then version 2.6: ${v["version"]}');
    }
    DbCollection coll = db.collection('testAggregate');
    coll.remove();

    // Avg 1 with 1 rating
    coll.insert({
      "game": "At the Gates of Loyang",
      "player": "Dallas",
      "rating": 1,
      "v": 1
    });

    // Avg 3 with 1 rating
    coll.insert(
        {"game": "Age of Steam", "player": "Paul", "rating": 3, "v": 1});

    // Avg 2 with 2 ratings
    coll.insert({"game": "Fresco", "player": "Erin", "rating": 3, "v": 1});
    coll.insert({"game": "Fresco", "player": "Dallas", "rating": 1, "v": 1});

    // Avg 3.5 with 4 ratings
    coll.insert(
        {"game": "Ticket To Ride", "player": "Paul", "rating": 4, "v": 1});
    coll.insert(
        {"game": "Ticket To Ride", "player": "Erin", "rating": 5, "v": 1});
    coll.insert(
        {"game": "Ticket To Ride", "player": "Dallas", "rating": 4, "v": 1});
    coll.insert(
        {"game": "Ticket To Ride", "player": "Anthony", "rating": 2, "v": 1});

    // Avg 4.5 with 4 ratings (counting only highest v)
    coll.insert({"game": "Dominion", "player": "Paul", "rating": 5, "v": 2});
    coll.insert({"game": "Dominion", "player": "Erin", "rating": 4, "v": 1});
    coll.insert({"game": "Dominion", "player": "Dallas", "rating": 4, "v": 1});
    coll.insert({"game": "Dominion", "player": "Anthony", "rating": 5, "v": 1});

    // Avg 5 with 2 ratings
    coll.insert({"game": "Pandemic", "player": "Erin", "rating": 5, "v": 1});
    coll.insert({"game": "Pandemic", "player": "Dallas", "rating": 5, "v": 1});

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
    // set batchSize parameter to split responce to 2 chunks
    return coll.aggregateToStream(pipeline, cursorOptions: {'batchSize': 1})
        .toList();
  }).then((v) {
    if (!skipTest) {
      expect(v.isNotEmpty, isTrue);
      expect(v[0]["_id"], "Age of Steam");
      expect(v[0]["avgRating"], 3);
    }
    return db.close();
  });
}

Future testSkip() async {
  for (int n = 0; n < 600; n++) {
    await collection.insert({"a": n});
  }

  var result = await collection.findOne(where.sortBy('a').skip(300));

  expect(result["a"], 300);
}

Future testUpdateWithUpsert() async {
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

  result = await collection.update(
      where.eq('key', 'a'),
      modify.set(
          'value', 'value_modified_for_only_one_with_multiupdate_false'),
      multiUpdate: false);
  expect(result['updatedExisting'], true);
  expect(result['n'], 1);

  results = await collection
      .find({'value': 'value_modified_for_only_one_with_multiupdate_false'})
      .toList();
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
  int counter = 0;
  Cursor cursor;
  for (int n = 0; n < 600; n++) {
    await collection.insert({"a": n});
  }

  cursor = collection.createCursor(where.sortBy('a').skip(300).limit(10));

  await cursor.stream.forEach((e) => counter++);
  expect(counter, 10);
  expect(cursor.state, State.CLOSED);
  expect(cursor.cursorId, 0);
}

Future testLimit() async {
  int counter = 0;
  Cursor cursor;
  for (int n = 0; n < 600; n++) {
    await collection.insert({"a": n});
  }

  cursor = collection.createCursor(where.limit(10));

  await cursor.stream.forEach((e) => counter++);
  expect(counter, 10);
  expect(cursor.state, State.CLOSED);
  expect(cursor.cursorId, 0);
}

testCursorCreation() {
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
  for (int n = 0; n < 100; n++) {
    await collection.insert({"a": n});
  }
  var cursor = new Cursor(db, collection, where.limit(10));

  await cursor.nextObject();

  expect(cursor.state, State.OPEN);
  expect(cursor.cursorId, isPositive);
}

Future testCursorGetMore() async {
  int count = 0;
  Cursor cursor;
  return db.open().then((c) {
    collection = db.collection('new_big_collection2');
    collection.remove();
    return db.getLastError();
  }).then((_) {
    cursor = new Cursor(db, collection, where.limit(10));
    return cursor.stream.forEach((v) {
      count++;
    });
  }).then((dummy) {
    expect(count, 0);
    List toInsert = new List();
    for (int n = 0; n < 1000; n++) {
      toInsert.add({"a": n});
    }
    collection.insertAll(toInsert);
    return db.getLastError();
  }).then((_) {
    cursor = new Cursor(db, collection, null);
    return cursor.stream.forEach((v) => count++);
  }).then((v) {
    expect(count, 1000);
    expect(cursor.cursorId, 0);
    expect(cursor.state, State.CLOSED);
    collection.remove();
    return db.close();
  });
}

Future testCursorClosing() async {
  for (int n = 0; n < 1000; n++) {
    await collection.insert({"a": n});
  }

  var cursor = collection.createCursor();
  expect(cursor.state, State.INIT);

  var newCursor = await cursor.nextObject();
  expect(cursor.state, State.OPEN);
  expect(cursor.cursorId, isPositive);

  await cursor.close();
  expect(cursor.state, State.CLOSED);
  expect(cursor.cursorId, 0);

  // TODO: I think there's an error with this
  // I believe it should be expect(result, isNotNull)
  // But this seems to be the original behaviour of the test
  var result = await collection.findOne();
  expect(newCursor, isNotNull);
}

Future testDbCommandCreation() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((d) {
    DbCommand dbCommand = new DbCommand(
        db,
        "student",
        0,
        0,
        1,
        {},
        {});
    expect('mongo_dart-test.student', dbCommand.collectionNameBson.value);
    db.close();
  });
}

Future testPingDbCommand() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((d) {
    DbCommand pingCommand = DbCommand.createPingCommand(db);
    Future<MongoReplyMessage> mapFuture = db.queryMessage(pingCommand);
    mapFuture.then((msg) {
      expect(msg.documents[0], containsPair('ok', 1));
      return db.close();
    });
  });
}

Future testDropDbCommand() {
  Db db = new Db('${DefaultUri}mongo_dart-test1');
  return db.open().then((d) {
    DbCommand command = DbCommand.createDropDatabaseCommand(db);
    Future<MongoReplyMessage> mapFuture = db.queryMessage(command);
    mapFuture.then((msg) {
      expect(msg.documents[0]["ok"], 1);
      return db.close();
    });
  });
}

Future testIsMasterDbCommand() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((d) {
    DbCommand isMasterCommand = DbCommand.createIsMasterCommand(db);
    Future<MongoReplyMessage> mapFuture = db.queryMessage(isMasterCommand);
    mapFuture.then((msg) {
      expect(msg.documents[0], containsPair('ok', 1));
      return db.close();
    });
  });
}

testAuthComponents() {
  var hash;
  var digest;
  hash = new MD5();
  hash.add(''.codeUnits);
  digest = new BsonBinary.from(hash.close()).hexString;
  expect(digest, 'd41d8cd98f00b204e9800998ecf8427e');
  hash = new MD5();
  hash.add('md4'.codeUnits);
  digest = new BsonBinary.from(hash.close()).hexString;
  expect(digest, 'c93d3bf7a7c4afe94b64e30c2ce39f4f');
  hash = new MD5();
  hash.add('md5'.codeUnits);
  digest = new BsonBinary.from(hash.close()).hexString;
  expect(digest, '1bc29b36f623ba82aaf6724fd3b16718');
  var nonce = '94505e7196beb570';
  var userName = 'dart';
  var password = 'test';
  var test_key = 'aea09fb38775830306c5ff6de964ff04';
  var md5 = new MD5();
  md5.add("${userName}:mongo:${password}".codeUnits);
  var hashed_password = new BsonBinary.from(md5.close()).hexString;
  md5 = new MD5();
  md5.add("${nonce}${userName}${hashed_password}".codeUnits);
  var key = new BsonBinary.from(md5.close()).hexString;
  expect(key, test_key);
}

Future testAuthentication() async {
  await db.authenticate('test', 'test');
}

Future testAuthenticationWithUri() async {
  await collection.insert({"a": 1});
  await collection.insert({"a": 2});
  await collection.insert({"a": 3});

  var foundValue = await collection.findOne();

  expect(foundValue['a'], isNotNull);
}

Future testGetIndexes() async {
  for (int n = 0; n < 100; n++) {
    await collection.insert({"a": n});
  }

  var indexes = await collection.getIndexes();

  expect(indexes.length, 1);
}

Future testIndexCreation() async {
  for (int n = 0; n < 6; n++) {
    await collection.insert({
      'a': n,
      'embedded': {'b': n, 'c': n * 10}
    });
  }
  var res = await db.createIndex('testcol', key: 'a');
  expect(res['ok'], 1.0);

  res = await db.createIndex('testcol', keys: {'a': -1, 'embedded.c': 1});
  expect(res['ok'], 1.0);

  var indexes = await collection.getIndexes();
  expect(indexes.length, 3);

  res = await db.ensureIndex('testcol', keys: {'a': -1, 'embedded.c': 1});
  expect(res['ok'], 1.0);
}

Future testEnsureIndexWithIndexCreation() {
  Db db = new Db('${DefaultUri}ensureIndex_indexCreation');
  DbCollection collection;
  return db.open().then((c) {
    collection = db.collection('testcol');
    return collection.drop();
  }).then((res) {
    for (int n = 0; n < 6; n++) {
      collection.insert({
        'a': n,
        'embedded': {'b': n, 'c': n * 10}
      });
    }
    return db.ensureIndex('testcol', keys: {'a': -1, 'embedded.c': 1});
  }).then((res) {
    expect(res['ok'], 1.0);
    expect(res['err'], isNull);
    return db.close();
  });
}

Future testIndexCreationErrorHandling() {
  Db db = new Db('${DefaultUri}IndexCreationErrorHandling');
  DbCollection collection;
  bool errorHandled = false;
  return db.open().then((c) {
    collection = db.collection('testcol');
    return collection.drop();
  }).then((res) {
    for (int n = 0; n < 6; n++) {
      collection.insert({'a': n});
    }
    // Insert dublicate
    collection.insert({'a': 3});
    return db.ensureIndex('testcol', key: 'a', unique: true).catchError((e) {
      errorHandled = true;
    });
  }).then((res) {
    expect(errorHandled, isTrue);
    return db.close();
  });
}

Future testSafeModeUpdate() {
  Db db = new Db('${DefaultUri}safe_mode');
  DbCollection collection = db.collection('testcol');
  return db.open().then((c) {
    collection.remove();
    for (int n = 0; n < 6; n++) {
      collection.insert({
        'a': n,
        'embedded': {'b': n, 'c': n * 10}
      });
    }
    return collection.update({'a': 200}, {'a': 100});
  }).then((res) {
    expect(res['updatedExisting'], false);
    expect(res['n'], 0);
    return collection.update({'a': 3}, {'a': 100});
  }).then((res) {
    expect(res['updatedExisting'], true);
    expect(res['n'], 1);
    return db.close();
  });
}

Future testFindWithFieldsClause() async {
  await collection.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);

  var result = await collection.findOne(
      where.eq('name', 'Vadim').fields(['score']));

  expect(result['name'], isNull);
  expect(result['score'], 4);
}

Future testSimpleQuery() async {
  ObjectId id;
  for (var n = 0; n < 10; n++) {
    await collection.insert({"my_field": n, "str_field": "str_$n"});
  }

  var result = await collection.find(where.gt("my_field", 5).sortBy('my_field'))
      .toList();
  expect(result.length, 4);
  expect(result[0]['my_field'], 6);

  result = await collection.findOne(where.eq('my_field', 3));
  expect(result, isNotNull);
  expect(result['my_field'], 3);
  id = result['_id'];

  result = await collection.findOne(where.id(id));
  expect(result, isNotNull);
  expect(result['my_field'], 3);

  collection.remove(where.id(id));
  result = await collection.findOne(where.eq('my_field', 3));
  expect(result, isNull);
}

Future testCompoundQuery() async {
  for (var n = 0; n < 10; n++) {
    await collection.insert({"my_field": n, "str_field": "str_$n"});
  }
  var result = await collection
      .find(where.gt("my_field", 8).or(where.lt('my_field', 2)))
      .toList();
  expect(result.length, 3);

  result = await collection.findOne(where
      .gt("my_field", 8)
      .or(where.lt('my_field', 2))
      .and(where.eq('str_field', 'str_1')));
  expect(result, isNotNull);
  expect(result['my_field'], 1);
}

Future testFieldLevelUpdateSimple() {
  ObjectId id;
  Db db = new Db('${DefaultUri}update');
  DbCollection collection = db.collection('testupdate');
  return db.open().then((c) {
    return collection.drop().then((_) {
      return collection.insert({'name': 'a', 'value': 10});
    }).then((result) {
      expect(result['n'], 0);
      return collection.findOne({'name': 'a'});
    }).then((result) {
      expect(result, isNotNull);
      id = result['_id'];
      return collection.update(where.id(id), modify.set('name', 'BBB'));
    }).then((result) {
      expect(result['updatedExisting'], true);
      expect(result['n'], 1);
      return collection.findOne(where.id(id));
    }).then((result) {
      expect(result, isNotNull);
      expect(result['name'], 'BBB');
      return db.close();
    });
  });
}

Future testQueryOnClosedConnection() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    return db.close().then((_) {
      return db.collection("test").find().toList().catchError((e) {
        expect(e is MongoDartError, isTrue);
        return "error_received";
      }).then((msg) {
        expect(msg, equals("error_received"));
      });
    });
  });
}

Future testUpdateOnClosedConnection() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    return db.close().then((_) {
      return db.collection("test").save({"test": "test"}).catchError((e) {
        expect(e is MongoDartError, isTrue);
        print(e);
        return "error_received";
      }).then((msg) {
        expect(msg, equals("error_received"));
      });
    });
  });
}

Future testReopeningDb() {
  var db = new Db('mongodb://127.0.0.1:27017/testdb');
  return db.open().then((_) {
    var coll = db.collection('test');
    return coll.insert({'one': 'test'});
  }).then((_) {
    return db.close();
  }).then((_) {
    return db.open();
  }).then((_) {
    var coll = db.collection('test');
    return coll.findOne();
  }).then((res) {
    expect(res, isNotNull);
    return db.close();
  });
}

Future testDbNotOpen() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection coll = db.collection('test');
  return coll.findOne().catchError((e) {
    expect(e is MongoDartError, isTrue);
    return "error_received";
  }).then((msg) {
    expect(msg, equals("error_received"));
  });
}

Future testDbOpenWhileStateIsOpening() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return new Future.sync(() {
    db.open().then((_) {
      return db.collection('Dubmmy').findOne();
    }).then((res) {
      expect(res, isNull);
      db.close();
    });
    db.open().then((_) {
      return db.collection('Dubmmy').findOne();
    }).then((res) {
      expect(res, isNull);
      ;
    }).catchError((e) {
      expect(e is MongoDartError, isTrue);
      expect(db.state == State.OPENING, isTrue);
    });
  });
}

Future testInvalidIndexCreationErrorHandling() {
  Db db = new Db('${DefaultUri}index_creation');
  return new Future.sync(() {
    db.open().then((_) {
      return db.createIndex('testcol', key: 'a');
    }).catchError((e) {
      expect(e is ArgumentError, isTrue);
    }).whenComplete(() {
      db.close();
    });
  });
}

Future testInvalidIndexCreationErrorHandling1() {
  Db db = new Db('${DefaultUri}index_creation');
  return new Future.sync(() {
    db.open().then((_) {
      return db.createIndex('testcol', key: 'a', keys: {'a': -1});
    }).catchError((e) {
      expect(e is ArgumentError, isTrue);
    }).whenComplete(() {
      db.close();
    });
  });
}

Future testFindOneWhileStateIsOpening() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return new Future.sync(() {
    db.open().then((_) {
      return db.collection('Dubmmy').findOne();
    }).then((res) {
      expect(res, isNull);
      db.close();
    });
    db.collection('Dubmmy').findOne().then((res) {
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
    collection = db.collection(collectionName);
  }

  Future cleanupDatabase() async {
    await collection.drop();
    await db.close();
  }

  group('DbCollection tests:', () {
    test('testAuthComponents', testAuthComponents);
  });

  group('DBCommand:', () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('testAuthentication', testAuthentication);
    test('testAuthenticationWithUri', testAuthenticationWithUri);
    test('testDropDatabase', testDropDatabase);
    test('testGetCollectionInfos', testGetCollectionInfos);
    test('testRemove', testRemove);
    test('testGetNonce', testGetNonce);
    test('getBuildInfo', getBuildInfo);
    test('testIsMaster', testIsMaster);
  });

  group('DbCollection tests:', () {
    setUp(() async {
      await initializeDatabase();
    });

    tearDown(() async {
      await cleanupDatabase();
    });

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
    test('testEnsureIndexWithIndexCreation', testEnsureIndexWithIndexCreation);
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

  group('Error handling:', () {
    test('testQueryOnClosedConnection', testQueryOnClosedConnection);
    test("testUpdateOnClosedConnection", testUpdateOnClosedConnection);
    test('testReopeningDb', testReopeningDb);
    test('testDbNotOpen', testDbNotOpen);
    test('testDbOpenWhileStateIsOpening', testDbOpenWhileStateIsOpening);
    test('testFindOneWhileStateIsOpening', testFindOneWhileStateIsOpening);
    test('testInvalidIndexCreationErrorHandling',
        testInvalidIndexCreationErrorHandling);
    test('testInvalidIndexCreationErrorHandling1',
        testInvalidIndexCreationErrorHandling1);
  });
}
