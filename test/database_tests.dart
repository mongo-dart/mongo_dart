library database_tests;
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:uri';
import 'dart:io';
import 'dart:crypto';
import 'package:unittest/unittest.dart';

const DefaultUri = 'mongodb://127.0.0.1/';
testSelectorBuilderCreation(){
  SelectorBuilder selector = where;
  expect(selector.map is Map, isTrue);
  expect(selector.map,isEmpty);
}
testSelectorBuilderOnObjectId(){
  ObjectId id = new ObjectId();
  SelectorBuilder selector = where.id(id);
  expect(selector.map is Map, isTrue);
  expect(selector.map.length,greaterThan(0));
}

testCollectionInfoCursor(){
  Db db = new Db('mongodb://127.0.0.1/mongo_dart-test');
  db.open().chain(expectAsync1((c){
    DbCollection newColl = db.collection("new_collecion");
    newColl.drop();
    newColl.insertAll([{"a":1}]);
    bool found = false;
    return db.collectionsInfoCursor("new_collecion").toList();
  })).then(expectAsync1((v){
    expect(v,hasLength(1));
    db.close();
  }));
}
testRemove(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection newColl;
  db.open().chain(expectAsync1((c){
    db.removeFromCollection("new_collecion_to_remove");
    newColl = db.collection("new_collecion_to_remove");
    newColl.insertAll([{"a":1}]);
  return db.collectionsInfoCursor("new_collecion_to_remove").toList();
  })).then(expectAsync1((v){
    expect(v,hasLength(1));
    db.removeFromCollection("new_collecion_to_remove");
    newColl.find().toList().then(expectAsync1((v1){
      expect(v1,isEmpty);
      newColl.drop();
      db.close();
    }));
  }));
}
testDropDatabase(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain((c){
    return db.drop();
  }).then((v){
     db.close();
  });
}
testGetNonce(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
    return db.getNonce();
  })).then(expectAsync1((v){
      expect(v["ok"],1);
      db.close();
  }));
}
testPwd(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection coll;
  db.open().chain(expectAsync1((c){
    coll = db.collection("system.users");
    return coll.find().each((user)=>print(user));
  })).then(expectAsync1((v){
      db.close();
  }));
}

testCollectionCreation(){
  Db db = new Db('${DefaultUri}db');
  DbCollection collection = db.collection('student');
}
testEachOnEmptyCollection(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int count = 0;
  int sum = 0;
  db.open().chain(expectAsync1((c){
    DbCollection newColl = db.collection('newColl1');
    return newColl.find().each((v)
      {sum += v["a"]; count++;});
  })).then(expectAsync1((v) {
    expect(sum, 0);
    expect(count, 0);
    db.close();
  }));
}
testFindEachWithThenClause(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int count = 0;
  int sum = 0;
  DbCollection students;
  db.open().chain(expectAsync1((c){
    students = db.collection('students');
    return students.drop();
  })).chain(expectAsync1((c){
    students.insertAll(
      [
      {"name":"Vadim","score":4},
      {"name": "Daniil","score":4},
      {"name": "Nick", "score": 5}
      ]
    );
    return students.find().each((v)
      {sum += v["score"]; count++;});
   })).then(expectAsync1((v){
    expect(sum,13);
    expect(count,3);
    db.close();
  }));
}
testFindEach(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int count = 0;
  int sum = 0;
  db.open().chain(expectAsync1((c){
    DbCollection students = db.collection('students');
    students.remove();
    students.insertAll(
    [
      {"name":"Vadim","score":4},
       {"name": "Daniil","score":4},
      {"name": "Nick", "score": 5}
    ]);
   return students.find().each((v1){
    count++;
    sum += v1["score"];});
  })).then(expectAsync1((v){
    expect(count,3);
    expect(sum,13);
    db.close();
   }));
}
testDrop(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((_){
    return db.dropCollection("testDrop");
  })).chain(expectAsync1((v) {
      return db.dropCollection("testDrop");
  })).then(expectAsync1((__){
      db.close();
  }));
}

testSaveWithIntegerId(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection coll;
  var id;
  db.open().chain(expectAsync1((c){
    coll = db.collection('testSaveWithIntegerId');
    coll.remove();
    List toInsert = [
                   {"_id":1,"name":"a", "value": 10},
                   {"_id":2,"name":"b", "value": 20},
                   {"_id":3,"name":"c", "value": 30},
                   {"_id":4,"name":"d", "value": 40}
                 ];
    coll.insertAll(toInsert);
    return coll.findOne({"name":"c"});
  })).chain(expectAsync1((v){
    expect(v["value"],30);
    return coll.findOne({"_id":3});
    })).chain(expectAsync1((v){
    v["value"] = 2;
    coll.save(v);
    return coll.findOne({"_id":3});
  })).then(expectAsync1((v1){
    expect(v1["value"],2);
    db.close();
  }));
}
testSaveWithObjectId(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection coll;
  var id;
  db.open().chain(expectAsync1((c){
    coll = db.collection('testSaveWithObjectId');
    coll.remove();
    List toInsert = [
                   {"name":"a", "value": 10},
                   {"name":"b", "value": 20},
                   {"name":"c", "value": 30},
                   {"name":"d", "value": 40}
                 ];
    coll.insertAll(toInsert);
    return coll.findOne({"name":"c"});
  })).chain(expectAsync1((v){
    expect(v["value"],30);
    id = v["_id"];
    return coll.findOne({"_id":id});
    })).chain(expectAsync1((v){
    expect(v["value"],30);
    v["value"] = 1;
    coll.save(v);
    return coll.findOne({"_id":id});
  })).then(expectAsync1((v1){
    expect(v1["value"],1);
    db.close();
  }));
}

testCount(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
    DbCollection coll = db.collection('testCount');
    coll.remove();
    for(int n=0;n<167;n++){
      coll.insert({"a":n});
        }
    return coll.count();
  })).then(expectAsync1((v){
    expect(v,167);
    db.close();
  }));
}
testSkip(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
    DbCollection coll = db.collection('testSkip');
    coll.remove();
    for(int n=0;n<600;n++){
      coll.insert({"a":n});
        }
    return coll.findOne(where.sortBy('a').skip(300));
  })).then(expectAsync1((v){
    expect(v["a"],300);
    db.close();
  }));
}
testLimit(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  int counter = 0;
  Cursor cursor;
  db.open().chain(expectAsync1((c){
    DbCollection coll = db.collection('testLimit');
    coll.remove();
    for(int n=0;n<600;n++){
      coll.insert({"a":n});
    }
    cursor = coll.find(where.sortBy('a').skip(300).limit(10));
    return cursor.each((e)=>counter++);
  })).then(expectAsync1((v){
    expect(counter,10);
    expect(cursor.state,Cursor.CLOSED);
    expect(cursor.cursorId,0);
    db.close();
  }));
}

testCursorCreation(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection = db.collection('student');
  Cursor cursor = new Cursor(db, collection, null);
}
testPingRaw(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
    DbCollection collection = db.collection('\$cmd');
    Cursor cursor = new Cursor(db,collection,where.eq('ping',1).limit(1));
    MongoQueryMessage queryMessage = cursor.generateQueryMessage();
    Future mapFuture = db.connection.query(queryMessage);
    return mapFuture;
  })).then(expectAsync1((msg) {
    expect(msg.documents[0],containsPair('ok', 1));
    db.close();
  }));
}
testNextObject(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
    DbCollection collection = db.collection('\$cmd');
    Cursor cursor = new Cursor(db,collection,where.eq('ping',1).limit(1));
    return cursor.nextObject();
  })).then(expectAsync1((v){
    expect(v,containsPair('ok', 1));
    db.close();
  }));
}
testNextObjectToEnd(){
  var res;
  Db db = new Db('${DefaultUri}mongo_dart-test');
  Cursor cursor;
  db.open().chain(expectAsync1((c){
    DbCollection collection = db.collection('testNextObjectToEnd');
    collection.remove();
    collection.insert({"a":1});
    collection.insert({"a":2});
    collection.insert({"a":3});
    cursor = new Cursor(db,collection,where.limit(10));
    return cursor.nextObject();
  })).then(expectAsync1((v){
    expect(v,isNotNull);
    res = cursor.nextObject();
    res.then(expectAsync1((v1){
      expect(v1,isNotNull);
      res = cursor.nextObject();
      res.then(expectAsync1((v2){
        expect(v2,isNotNull);
        res = cursor.nextObject();
        res.then(expectAsync1((v3){
          expect(v3,isNull);
          db.close();
        }));
      }));
    }));
  }));
}

testCursorWithOpenServerCursor(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  Cursor cursor;
  db.open().chain(expectAsync1((c){
    DbCollection collection = db.collection('new_big_collection');
    collection.remove();
    for (int n=0;n < 100; n++){
      collection.insert({"a":n});
    }
    cursor = new Cursor(db,collection,where.limit(10));
    return cursor.nextObject();
  })).then(expectAsync1((v){
    expect(cursor.state, Cursor.OPEN);
    expect(cursor.cursorId, isPositive);
    db.close();
  }));
}
testCursorGetMore(){
  var res;
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection;
  int count = 0;
  Cursor cursor;
  db.open().chain(expectAsync1((c){
    collection = db.collection('new_big_collection2');
    collection.remove();
    return db.getLastError();
  })).chain(expectAsync1((_){
    cursor = new Cursor(db,collection,where.limit(10));
    return cursor.each((v){
     count++;
    });
  })).chain(expectAsync1((dummy){
    expect(count,0);
    List toInsert = new List();
    for (int n=0;n < 1000; n++){
      toInsert.add({"a":n});
    }
    collection.insertAll(toInsert);
    return db.getLastError();
  })).chain(expectAsync1((_){
    cursor = new Cursor(db,collection,where.limit(10));
    return cursor.each((v)=>count++);
  })).then(expectAsync1((v){
    expect(count,1000);
    expect(cursor.cursorId,0);
    expect(cursor.state,Cursor.CLOSED);
    collection.remove();
    db.close();
  }));
}
testCursorClosing(){
  var res;
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCollection collection;
  Cursor cursor;
  db.open().chain(expectAsync1((c){
    collection = db.collection('new_big_collection1');
    collection.remove();
    for (int n=0;n < 1000; n++){
      collection.insert({"a":n});
      }
    int count = 0;
    cursor = collection.find();
    expect(cursor.state,Cursor.INIT);
    return cursor.nextObject();
  })).then(expectAsync1((v){
    expect(cursor.state,Cursor.OPEN);
    expect(cursor.cursorId,isPositive);
    cursor.close();
    expect(cursor.state,Cursor.CLOSED);
    expect(cursor.cursorId,0);
    collection.findOne().then(expectAsync1((v1){
      expect(v,isNotNull);
      db.close();
    }));
  }));
}

testDbCommandCreation(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  DbCommand dbCommand = new DbCommand(db,"student",0,0,1,{},{});
  expect('mongo_dart-test.student',dbCommand.collectionNameBson.value);
}
testPingDbCommand(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then((d){
    DbCommand pingCommand = DbCommand.createPingCommand(db);
    Future<MongoReplyMessage> mapFuture = db.queryMessage(pingCommand);
    mapFuture.then((msg) {
      expect(msg.documents[0],containsPair('ok', 1));
      db.close();
    });
  });
}
testDropDbCommand(){
  Db db = new Db('${DefaultUri}mongo_dart-test1');
  db.open().then((d){
    DbCommand command = DbCommand.createDropDatabaseCommand(db);
    Future<MongoReplyMessage> mapFuture = db.queryMessage(command);
    mapFuture.then((msg) {
      expect(msg.documents[0]["ok"],1);
      db.close();
    });
  });
}

testAuthComponents(){
  var hash;
  var digest;
  hash = new MD5();
  hash.update(''.charCodes);
  digest = new BsonBinary.from(hash.digest()).hexString;
  expect(digest,'d41d8cd98f00b204e9800998ecf8427e');
  hash = new MD5();
  hash.update('md4'.charCodes);
  digest = new BsonBinary.from(hash.digest()).hexString;
  expect(digest,'c93d3bf7a7c4afe94b64e30c2ce39f4f');
  hash = new MD5();
  hash.update('md5'.charCodes);
  digest = new BsonBinary.from(hash.digest()).hexString;
  expect(digest,'1bc29b36f623ba82aaf6724fd3b16718');
  var nonce = '94505e7196beb570';
  var userName = 'dart';
  var password = 'test';
  var test_key = 'aea09fb38775830306c5ff6de964ff04';
  var md5 = new MD5();
  md5.update("${userName}:mongo:${password}".charCodes);
  var hashed_password = new BsonBinary.from(md5.digest()).hexString;
  md5 = new MD5();
  md5.update("${nonce}${userName}${hashed_password}".charCodes);
  var key = new BsonBinary.from(md5.digest()).hexString;
  expect(key,test_key);
}

testAuthentication(){
  var db = new Db('mongodb://ds031477.mongolab.com:31477/dart');
  db.open().chain(expectAsync1((c){
    return db.authenticate('dart','test');
  })).then(expectAsync1((v){
    db.close();
  }));
}
testAuthenticationWithUri(){
  var db = new Db('mongodb://dart:test@ds031477.mongolab.com:31477/dart');
  db.open().chain(expectAsync1((c){
    DbCollection collection = db.collection('testAuthenticationWithUri');
    collection.remove();
    collection.insert({"a":1});
    collection.insert({"a":2});
    collection.insert({"a":3});
    return collection.findOne();
  })).then(expectAsync1((v){
    expect(v['a'],isNotNull);
    db.close();
  }));
}

testMongoDbUri(){
  var connStr = 'mongodb://dart:test@ds031477.mongolab.com:31477/dart';
  var db = new Db(connStr);
  expect(db.serverConfig.userName,'dart');
  expect(db.databaseName,'dart');
  expect(db.serverConfig.host,'ds031477.mongolab.com');
  expect(db.serverConfig.port,31477);
  expect(db.serverConfig.password,'test');
  connStr = "mongodb://127.0.0.1/DartTest";
  db = new Db(connStr);
  expect(db.serverConfig.userName,isNull);
  expect(db.serverConfig.host,'127.0.0.1');
  expect(db.serverConfig.port,27017);
  expect(db.databaseName,'DartTest');
  expect(db.serverConfig.password,isNull);
}

testIndexInformation(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  Cursor cursor;
  db.open().chain(expectAsync1((c){
    DbCollection collection = db.collection('testcol');
    collection.remove();
    for (int n=0;n < 100; n++){
      collection.insert({"a":n});
    }
    return db.indexInformation('testcol');
  })).then(expectAsync1((indexInfo){
    expect(indexInfo.length,1);
    db.close();
  }));
}

testIndexCreation(){
  Db db = new Db('${DefaultUri}index_creation');
  Cursor cursor;
  DbCollection collection;
  db.open().chain(expectAsync1((c){
    collection = db.collection('testcol');
    return collection.drop();
  })).chain(expectAsync1((res){
    for (int n=0;n < 6; n++){
      collection.insert({'a':n, 'embedded': {'b': n, 'c': n * 10}});
    }
    expect(() => db.createIndex('testcol'),throws, reason: 'Invalid number of arguments');
    expect(() => db.createIndex('testcol',key: 'a', keys:{'a':-1}),throws, reason: 'Invalid number of arguments');
    return db.createIndex('testcol',key:'a');
  })).chain(expectAsync1((res){
    expect(res['ok'],1.0);
    return db.createIndex('testcol',keys:{'a':-1,'embedded.c': 1});
  })).chain(expectAsync1((res){
    expect(res['ok'],1.0);
    return db.indexInformation('testcol');
  })).chain(expectAsync1((res){
    expect(res.length, 3);
    return db.ensureIndex('testcol',keys:{'a':-1,'embedded.c': 1});
  })).then(expectAsync1((res){
    expect(res['ok'],1.0);
    expect(res['result'],'index preexists');
    db.close();
  }));
}

testSafeModeUpdate(){
  Db db = new Db('${DefaultUri}safe_mode');
  Cursor cursor;
  DbCollection collection = db.collection('testcol');
  db.open().chain(expectAsync1((c){
    collection.remove();
    for (int n=0;n < 6; n++){
      collection.insert({'a':n, 'embedded': {'b': n, 'c': n * 10}});
    }
    return collection.update({'a': 200}, {'a':100}, safeMode: true);
  })).chain(expectAsync1((res){
    expect(res['updatedExisting'], false);
    expect(res['n'], 0);
    return collection.update({'a': 3}, {'a':100}, safeMode: true);
  })).then(expectAsync1((res){
    expect(res['updatedExisting'], true);
    expect(res['n'], 1);
    db.close();
  }));
}



main(){
  initBsonPlatform();
  group('DbCollection tests:', (){
    test('testSelectorBuilderCreation',testSelectorBuilderCreation);
    test('testSelectorBuilderOnObjectId',testSelectorBuilderOnObjectId);
    test('testAuthComponents',testAuthComponents);
    test('testMongoDbUri',testMongoDbUri);
  });
  group('DBCommand:', (){
    test('testAuthentication',testAuthentication);
    test('testAuthenticationWithUri',testAuthenticationWithUri);
    test('testDropDatabase',testDropDatabase);
    test('testCollectionInfoCursor',testCollectionInfoCursor);
    test('testRemove',testRemove);
    test('testGetNonce',testGetNonce);
    test('testPwd',testPwd);
  });
  group('DbCollection tests:', (){
    test('testLimit',testLimit);
    test('testFindEachWithThenClause',testFindEachWithThenClause);
    test('testCount',testCount);
    test('testFindEach',testFindEach);
    test('testEach',testEachOnEmptyCollection);
    test('testDrop',testDrop);
    test('testSaveWithIntegerId',testSaveWithIntegerId);
    test('testSaveWithObjectId',testSaveWithObjectId);
    test('testSkip',testSkip);
  });  
  group('Cursor tests:', (){
    test('testCursorCreation',testCursorCreation);
    test('testCursorClosing',testCursorClosing);
    test('testNextObjectToEnd',testNextObjectToEnd);
    test('testPingRaw',testPingRaw);
    test('testNextObject',testNextObject);
    test('testCursorWithOpenServerCursor',testCursorWithOpenServerCursor);
    test('testCursorGetMore',testCursorGetMore);
  });  
  group('DBCommand tests:', (){
    test('testDbCommandCreation',testDbCommandCreation);
    test('testPingDbCommand',testPingDbCommand);
    test('testDropDbCommand',testDropDbCommand);
  });
  group('Safe mode tests:', () {
    test('testSafeModeUpdate',testSafeModeUpdate);
  });  
  group('Indexes tests:', () {
    test('testIndexInformation',testIndexInformation);
    test('testIndexCreation',testIndexCreation);
  });
}