library database_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'package:test/test.dart';

const DefaultUri = 'mongodb://127.0.0.1:27017/';

Future testGetCollectionInfos() {
  Db db = new Db(
      'mongodb://127.0.0.1:27017/mongo_dart-test', 'testCollectionInfoCursor');
  DbCollection newColl;
  return db.open().then((c) {
    newColl = db.collection("new_collecion");
    return newColl.remove();
  }).then((v) {
    return newColl.insertAll([
      {"a": 1}
    ]);
  }).then((v) {
    return db.getCollectionInfos({'name': 'new_collecion'});
  }).then((v) {
    expect(v, hasLength(1));
    return db.close();
  });
}

Future testRemove() async {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection newColl;
  await db.open();
  db.removeFromCollection("new_collecion_to_remove");
  newColl = db.collection("new_collecion_to_remove");
  newColl.insertAll([
    {"a": 1}
  ]);
  var v = await db.getCollectionInfos({'name': 'new_collecion_to_remove'});
  expect(v, hasLength(1));
  await db.removeFromCollection("new_collecion_to_remove");
  var v1 = await newColl.find().toList();
  expect(v1, isEmpty);
  await newColl.drop();
  await db.close();
}

Future testDropDatabase() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    return db.drop();
  }).then((v) {
    return db.close();
  });
}

Future testGetNonce() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    return db.getNonce();
  }).then((v) {
    expect(v["ok"], 1);
    return db.close();
  });
}

Future getBuildInfo() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    return db.getBuildInfo();
  }).then((v) {
    expect(v["ok"], 1);
    return db.close();
  });
}


Future testIsMaster() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    return db.isMaster();
  }).then((v) {
    expect(v["ok"], 1);
    return db.close();
  });
}

testCollectionCreation() {
  Db db = new Db('${DefaultUri}db');
  DbCollection collection = db.collection('student');
  return collection;
}

Future testEachOnEmptyCollection() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testEachOnEmptyCollection');
  int count = 0;
  int sum = 0;
  return db.open().then((c) {
    DbCollection newColl = db.collection('newColl1');
    return newColl.find().forEach((v) {
      sum += v["a"];
      count++;
    });
  }).then((v) {
    expect(sum, 0);
    expect(count, 0);
    return db.close();
  });
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

Future testDateTime() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection testDates;
  return db.open().then((c) {
    testDates = db.collection('testDates');
    return testDates.drop();
  }).then((c) {
    return testDates.insertAll([
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
  }).then((_) {
    return testDates
        .find(where.lt('posted_on', new DateTime.utc(2013, 1, 5)))
        .toList();
  }).then((v) {
    expect(v is List, isTrue);
    expect(v.length, 4);
    return db.close();
  });
}

testFindEach() async {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int count = 0;
  int sum = 0;
  await db.open();
  DbCollection students = db.collection('students');
  await students.remove();
  await students.insertAll([
    {"name": "Vadim", "score": 4},
    {"name": "Daniil", "score": 4},
    {"name": "Nick", "score": 5}
  ]);
  var v = await students.find().forEach((v1) {
    count++;
    sum += v1["score"];
  });
  expect(count, 3);
  expect(sum, 13);
  await db.close();
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

Future testDrop() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((_) {
    return db.dropCollection("testDrop");
  }).then((v) {
    return db.dropCollection("testDrop");
  }).then((__) {
    return db.close();
  });
}

Future testSaveWithIntegerId() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection coll;
  return db.open().then((c) {
    coll = db.collection('testSaveWithIntegerId');
    coll.remove();
    List toInsert = [
      {"_id": 1, "name": "a", "value": 10},
      {"_id": 2, "name": "b", "value": 20},
      {"_id": 3, "name": "c", "value": 30},
      {"_id": 4, "name": "d", "value": 40}
    ];
    coll.insertAll(toInsert);
    return coll.findOne({"name": "c"});
  }).then((v) {
    expect(v["value"], 30);
    return coll.findOne({"_id": 3});
  }).then((v) {
    v["value"] = 2;
    coll.save(v);
    return coll.findOne({"_id": 3});
  }).then((v1) {
    expect(v1["value"], 2);
    return coll.findOne(where.eq("_id", 3));
  }).then((v1) {
    expect(v1["value"], 2);
    final notThere = {"_id": 5, "name": "d", "value": 50};
    coll.save(notThere);
    return coll.findOne(where.eq("_id", 5));
  }).then((v5) {
    expect(v5["value"], 50);
    return db.close();
  });
}

Future testSaveWithObjectId() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testSaveWithObjectId');
  DbCollection coll;
  var id;
  return db.open().then((c) {
    coll = db.collection('testSaveWithObjectId');
    coll.remove();
    List toInsert = [
      {"name": "a", "value": 10},
      {"name": "b", "value": 20},
      {"name": "c", "value": 30},
      {"name": "d", "value": 40}
    ];
    coll.insertAll(toInsert);
    return coll.findOne({"name": "c"});
  }).then((v) {
    expect(v["value"], 30);
    id = v["_id"];
    return coll.findOne({"_id": id});
  }).then((v) {
    expect(v["value"], 30);
    v["value"] = 1;
    coll.save(v);
    return coll.findOne({"_id": id});
  }).then((v1) {
    expect(v1["value"], 1);
    return db.close();
  });
}

Future testInsertWithObjectId() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection coll;
  var id;
  var objectToSave;
  return db.open().then((c) {
    coll = db.collection('testInsertWithObjectId');
    coll.remove();
    objectToSave = {"_id": new ObjectId(), "name": "a", "value": 10};
    id = objectToSave["_id"];
    coll.insert(objectToSave);
    return coll.findOne(where.eq("name", "a"));
  }).then((v1) {
    expect(v1["_id"], id);
    expect(v1["value"], 10);
    return db.close();
  });
}

Future testCount() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    DbCollection coll = db.collection('testCount');
    coll.remove();
    for (int n = 0; n < 167; n++) {
      coll.insert({"a": n});
    }
    return coll.count();
  }).then((v) {
    expect(v, 167);
    return db.close();
  });
}

Future testDistinct() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testDistinct');
  return db.open().then((c) {
    DbCollection coll = db.collection('testDistinct');
    coll.remove();
    coll.insert({"foo": 1});
    coll.insert({"foo": 2});
    coll.insert({"foo": 2});
    coll.insert({"foo": 3});
    coll.insert({"foo": 3});
    coll.insert({"foo": 3});
    return coll.distinct("foo");
  }).then((v) {
    List values = v['values'];
    expect(values[0], 1);
    expect(values[1], 2);
    expect(values[2], 3);
    return db.close();
  });
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

Future testSkip() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testSkip');
  return db.open().then((c) {
    DbCollection coll = db.collection('testSkip');
    coll.remove();
    for (int n = 0; n < 600; n++) {
      coll.insert({"a": n});
    }
    return coll.findOne(where.sortBy('a').skip(300));
  }).then((v) {
    expect(v["a"], 300);
    return db.close();
  });
}

Future testUpdateWithUpsert() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection = db.collection('testupdateWithUpsert');
  return db.open().then((c) {
    return collection.drop().then((_) {
      return collection.insert({'name': 'a', 'value': 10});
    }).then((result) {
      expect(result['n'], 0);
      return collection.find({'name': 'a'}).toList();
    }).then((results) {
      expect(results.length, 1);
      expect(results.first['name'], 'a');
      expect(results.first['value'], 10);
    }).then((result) {
      var objectUpdate = {
        r'$set': {'value': 20}
      };
      return collection.update({'name': 'a'}, objectUpdate);
    }).then((result) {
      expect(result['updatedExisting'], true);
      expect(result['n'], 1);
      return collection.find({'name': 'a'}).toList();
    }).then((results) {
      expect(results.length, 1);
      expect(results.first['value'], 20);
      return db.close();
    });
  });
}

Future testUpdateWithMultiUpdate() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection = db.collection('testupdateWitMultiUpdate');
  return db.open().then((c) {
    return collection.drop().then((_) {
      return collection.insertAll([
        {'key': 'a', 'value': 'initial_value1'},
        {'key': 'a', 'value': 'initial_value2'},
        {'key': 'b', 'value': 'initial_value_b'}
      ]);
    }).then((result) {
      expect(result['n'], 0);
      return collection.find({'key': 'a'}).toList();
    }).then((results) {
      expect(results.length, 2);
      expect(results.first['key'], 'a');
      expect(results.first['value'], 'initial_value1');
    }).then((result) {
      return collection.update(where.eq('key', 'a'),
          modify.set('value', 'value_modified_for_only_one_with_default'));
    }).then((result) {
      expect(result['updatedExisting'], true);
      expect(result['n'], 1);
      return collection
          .find({'value': 'value_modified_for_only_one_with_default'}).toList();
    }).then((results) {
      expect(results.length, 1);
    }).then((result) {
      return collection.update(
          where.eq('key', 'a'),
          modify.set(
              'value', 'value_modified_for_only_one_with_multiupdate_false'),
          multiUpdate: false);
    }).then((result) {
      expect(result['updatedExisting'], true);
      expect(result['n'], 1);
      return collection
          .find({'value': 'value_modified_for_only_one_with_multiupdate_false'})
          .toList();
    }).then((results) {
      expect(results.length, 1);
    }).then((result) {
      return collection.update(
          where.eq('key', 'a'), modify.set('value', 'new_value'),
          multiUpdate: true);
    }).then((result) {
      expect(result['updatedExisting'], true);
      expect(result['n'], 2);
      return collection.find({'value': 'new_value'}).toList();
    }).then((results) {
      expect(results.length, 2);
      return collection.find({'key': 'b'}).toList();
    }).then((results) {
      expect(results.length, 1);
      expect(results.first['value'], 'initial_value_b');
      return db.close();
    });
  });
}

Future testLimitWithSortByAndSkip() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testLimitWithSortByAndSkip');
  int counter = 0;
  Cursor cursor;
  return db.open().then((c) {
    DbCollection coll = db.collection('testLimit');
    coll.remove();
    for (int n = 0; n < 600; n++) {
      coll.insert({"a": n});
    }
    cursor = coll.createCursor(where.sortBy('a').skip(300).limit(10));
    return cursor.stream.forEach((e) => counter++);
  }).then((v) {
    expect(counter, 10);
    expect(cursor.state, State.CLOSED);
    expect(cursor.cursorId, 0);
    return db.close();
  });
}

Future testLimit() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testLimit');
  int counter = 0;
  Cursor cursor;
  return db.open().then((c) {
    DbCollection coll = db.collection('testLimit');
    coll.remove();
    for (int n = 0; n < 600; n++) {
      coll.insert({"a": n});
    }
    cursor = coll.createCursor(where.limit(10));
    return cursor.stream.forEach((e) => counter++);
  }).then((v) {
    expect(counter, 10);
    expect(cursor.state, State.CLOSED);
    expect(cursor.cursorId, 0);
    return db.close();
  });
}

testCursorCreation() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection = db.collection('student');
  Cursor cursor = new Cursor(db, collection, null);
  return cursor;
}

Future testPingRaw() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    DbCollection collection = db.collection('\$cmd');
    Cursor cursor = new Cursor(db, collection, where.eq('ping', 1).limit(1));
    MongoQueryMessage queryMessage = cursor.generateQueryMessage();
    Future mapFuture = db.queryMessage(queryMessage);
    return mapFuture;
  }).then((msg) {
    expect(msg.documents[0], containsPair('ok', 1));
    return db.close();
  });
}

Future testNextObject() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    DbCollection collection = db.collection('\$cmd');
    Cursor cursor = new Cursor(db, collection, where.eq('ping', 1).limit(1));
    return cursor.nextObject();
  }).then((v) {
    expect(v, containsPair('ok', 1));
    return db.close();
  });
}

Future testNextObjectToEnd() {
  var res;
  Db db = new Db('${DefaultUri}mongo_dart-test');
  Cursor cursor;
  return db.open().then((c) {
    DbCollection collection = db.collection('testNextObjectToEnd');
    collection.remove();
    collection.insert({"a": 1});
    collection.insert({"a": 2});
    collection.insert({"a": 3});
    cursor = new Cursor(db, collection, where.limit(10));
    return cursor.nextObject();
  }).then((v) {
    expect(v, isNotNull);
    res = cursor.nextObject();
    res.then((v1) {
      expect(v1, isNotNull);
      res = cursor.nextObject();
      res.then((v2) {
        expect(v2, isNotNull);
        res = cursor.nextObject();
        res.then((v3) {
          expect(v3, isNull);
          return db.close();
        });
      });
    });
  });
}

Future testCursorWithOpenServerCursor() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  Cursor cursor;
  return db.open().then((c) {
    DbCollection collection = db.collection('new_big_collection');
    collection.remove();
    for (int n = 0; n < 100; n++) {
      collection.insert({"a": n});
    }
    cursor = new Cursor(db, collection, where.limit(10));
    return cursor.nextObject();
  }).then((v) {
    expect(cursor.state, State.OPEN);
    expect(cursor.cursorId, isPositive);
    return db.close();
  });
}

Future testCursorGetMore() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection;
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

Future testCursorClosing() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testCursorClosing');
  DbCollection collection;
  Cursor cursor;
  return db.open().then((c) {
    collection = db.collection('new_big_collection1');
    collection.remove();
    for (int n = 0; n < 1000; n++) {
      collection.insert({"a": n});
    }
    cursor = collection.createCursor();
    expect(cursor.state, State.INIT);
    return cursor.nextObject();
  }).then((v) {
    expect(cursor.state, State.OPEN);
    expect(cursor.cursorId, isPositive);
    cursor.close();
    expect(cursor.state, State.CLOSED);
    expect(cursor.cursorId, 0);
    collection.findOne().then((v1) {
      expect(v, isNotNull);
      return db.close();
    });
  });
}

Future testDbCommandCreation() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((d) {
    DbCommand dbCommand = new DbCommand(db, "student", 0, 0, 1, {}, {});
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

Future testAuthentication() {
  var db = new Db(
      'mongodb://ds031477.mongolab.com:31477/dart', 'testAuthentication');
  return db.open().then((c) {
    return db.authenticate('test', 'test');
  }).then((v) {
    return db.close();
  });
}

Future testAuthenticationWithUri() {
  var db = new Db('mongodb://test:test@ds031477.mongolab.com:31477/dart');
  return db.open().then((c) {
    DbCollection collection = db.collection('testAuthenticationWithUri');
    collection.remove();
    collection.insert({"a": 1});
    collection.insert({"a": 2});
    collection.insert({"a": 3});
    return collection.findOne();
  }).then((v) {
    expect(v['a'], isNotNull);
    return db.close();
  });
}

Future testGetIndexes() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c) {
    DbCollection collection = db.collection('testcol');
    collection.remove();
    for (int n = 0; n < 100; n++) {
      collection.insert({"a": n});
    }
    //return db.indexInformation('testcol');
    return collection.getIndexes();
  }).then((indexInfo) {
    expect(indexInfo.length, 1);
    return db.close();
  });
}

Future testIndexCreation() {
  Db db = new Db('${DefaultUri}index_creation');
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
//    expect(() => db.createIndex('testcol'),throws, reason: 'Invalid number of arguments');
//    expect(() => db.createIndex('testcol',key: 'a', keys:{'a':-1}),throws, reason: 'Invalid number of arguments');
    return db.createIndex('testcol', key: 'a');
  }).then((res) {
    expect(res['ok'], 1.0);
    return db.createIndex('testcol', keys: {'a': -1, 'embedded.c': 1});
  }).then((res) {
    expect(res['ok'], 1.0);
    return collection.getIndexes();
  }).then((res) {
    expect(res.length, 3);
    return db.ensureIndex('testcol', keys: {'a': -1, 'embedded.c': 1});
  }).then((res) {
    expect(res['ok'], 1.0);
    return db.close();
  });
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

Future testFindWithFieldsClause() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testFindWithFieldsClause');
  return db.open().then((c) {
    DbCollection students = db.collection('students');
    students.remove();
    students.insertAll([
      {"name": "Vadim", "score": 4},
      {"name": "Daniil", "score": 4},
      {"name": "Nick", "score": 5}
    ]);
    return students.findOne(where.eq('name', 'Vadim').fields(['score']));
  }).then((v) {
    expect(v['name'], isNull);
    expect(v['score'], 4);
    return db.close();
  });
}

Future testSimpleQuery() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  ObjectId id;
  DbCollection coll;
  return db.open().then((c) {
    coll = db.collection("simple_data");
    coll.remove();
    for (var n = 0; n < 10; n++) {
      coll.insert({"my_field": n, "str_field": "str_$n"});
    }
    return coll.find(where.gt("my_field", 5).sortBy('my_field')).toList();
  }).then((result) {
    expect(result.length, 4);
    expect(result[0]['my_field'], 6);
    return coll.findOne(where.eq('my_field', 3));
  }).then((v) {
    expect(v, isNotNull);
    expect(v['my_field'], 3);
    id = v['_id'];
    return coll.findOne(where.id(id));
  }).then((v) {
    expect(v, isNotNull);
    expect(v['my_field'], 3);
    coll.remove(where.id(id));
    return coll.findOne(where.eq('my_field', 3));
  }).then((v) {
    expect(v, isNull);
    return db.close();
  });
}

Future testCompoundQuery() {
  Db db = new Db('${DefaultUri}mongo_dart-test', 'testCompoundQuery');
  DbCollection coll;
  return db.open().then((c) {
    coll = db.collection("simple_data");
    coll.remove();
    for (var n = 0; n < 10; n++) {
      coll.insert({"my_field": n, "str_field": "str_$n"});
    }
    return coll
        .find(where.gt("my_field", 8).or(where.lt('my_field', 2)))
        .toList();
  }).then((result) {
    expect(result.length, 3);
    return coll.findOne(where
        .gt("my_field", 8)
        .or(where.lt('my_field', 2))
        .and(where.eq('str_field', 'str_1')));
  }).then((v) {
    expect(v, isNotNull);
    expect(v['my_field'], 1);
    return db.close();
  });
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
//  hierarchicalLoggingEnabled = true;
//  Logger.root.level = Level.OFF;
//  new Logger('Db').level = Level.ALL;
//  var listener = (LogRecord r) {
//    var name = r.loggerName;
//    if (name.length > 15) {
//      name = name.substring(0, 15);
//    }
//    while (name.length < 15) {
//      name = "$name ";
//    }
//    print("${r.time}: $name: ${r.message}");
//  };
//  Logger.root.onRecord.listen(listener);
//

  group('DbCollection tests:', () {
    test('testAuthComponents', testAuthComponents);
  });
  group('DBCommand:', () {
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
    test('testInsertWithObjectId', testSaveWithObjectId);
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
