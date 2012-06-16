#library("Database tests");
#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("../lib/bson/bson_vm.dart");
#import("dart:io");
#import("dart:builtin");
#import('../third_party/unittest/unittest.dart');
testSelectorBuilderCreation(){
  SelectorBuilder selector = query();
  expect(selector is Map);
  expect(selector,isEmpty);
}
testSelectorBuilderOnObjectId(){
  ObjectId id = new ObjectId();
  SelectorBuilder selector = query().id(id);
  expect(selector is Map);
  expect(selector.length,greaterThan(0));  
}


testDatabaseName(){
  Db db = new Db('mongo-dart-test');
  String dbName;
  dbName = 'mongo-dart-test';
  db.validateDatabaseName(dbName);
  dbName = 'mongo-dart-test';
  db.validateDatabaseName(dbName);  
}

testCollectionInfoCursor(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){
    DbCollection newColl = db.collection("new_collecion");
    newColl.drop();
    newColl.insertAll([{"a":1}]);
    bool found = false;
    return db.collectionsInfoCursor("new_collecion").toList();
  }).then((v){
    expect(v,hasLength(1));
    db.close();
    callbackDone();
  });
}
testRemove(){
  Db db = new Db('mongo-dart-test');
  DbCollection newColl;
  db.open().chain((c){  
    db.removeFromCollection("new_collecion_to_remove");
    newColl = db.collection("new_collecion_to_remove");  
    newColl.insertAll([{"a":1}]);
  return db.collectionsInfoCursor("new_collecion_to_remove").toList();
  }).then((v){    
    expect(v,hasLength(1));
    db.removeFromCollection("new_collecion_to_remove");
    //db.getLastError().then((v)=>print("remove result: $v"));
    newColl.find().toList().then((v1){
      expect(v1,isEmpty);
      newColl.drop();
      db.close();
      callbackDone();
   });
  });
}
testDropDatabase(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){
    return db.drop();
  }).then((v){
     db.close();
     callbackDone();
  });
}
testGetNonce(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){
    return db.getNonce();
  }).then((v){
      expect(v["ok"],1);
      db.close();
      callbackDone();
  }); 
}
testPwd(){
  Db db = new Db('mongo-dart-test');
  DbCollection coll;
  db.open().chain((c){
    coll = db.collection("system.users");
    return coll.find().each((user)=>print(user));
  }).then((v){
      db.close();
      callbackDone();
  }); 
}

testCollectionCreation(){
  Db db = new Db('db');
  DbCollection collection = db.collection('student');
}
testEach(){
  Db db = new Db('mongo-dart-test');
  int count = 0;
  int sum = 0;  
  db.open().chain((c){  
    DbCollection newColl = db.collection('newColl1');
    return newColl.find().each((v)
      {sum += v["a"]; count++;});
  }).then((v)=>info("Completed. Sum = $sum, count = $count"));
}
testFindEachWithThenClause(){
  Db db = new Db('mongo-dart-test');
  int count = 0;
  int sum = 0;  
  db.open().chain((c){  
    DbCollection students = db.collection('students');
    students.drop();
    students.insertAll(
      [
      {"name":"Vadim","score":4},
      {"name": "Daniil","score":4},
      {"name": "Nick", "score": 5}
      ]
    );
    return students.find().each((v)
      {sum += v["score"]; count++;});
   }).then((v){
    info("Students Completed. Sum = $sum, count = $count average score = ${sum/count}");    
    db.close();
    callbackDone();
  });
}
testFindEach(){
  Db db = new Db('mongo-dart-test');
  int count = 0;
  int sum = 0;  
  db.open().chain((c){  
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
  }).then((v){
    expect(count,3);
    expect(sum,13);
    db.close();
    callbackDone();
   });
  
}
testDrop(){
  Db db = new Db('mongo-dart-test');
  db.open().then((_){
  db.dropCollection("testDrop").then((v)=>v);
  db.dropCollection("testDrop").then((__){    
    db.close();
    callbackDone();    
  });
  });
}  

testSaveWithIntegerId(){
  Db db = new Db('mongo-dart-test');
  DbCollection coll;
  var id;
  db.open().chain((c){  
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
  }).chain((v){  
    expect(v["value"],30);    
    return coll.findOne({"_id":3});
    }).chain((v){  
    v["value"] = 2;    
    coll.save(v);
    return coll.findOne({"_id":3});
  }).then((v1){
    expect(v1["value"],2);    
    db.close();
    callbackDone();
  });      
}
testSaveWithObjectId(){
  Db db = new Db('mongo-dart-test');
  DbCollection coll;
  var id;
  db.open().chain((c){  
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
  }).chain((v){  
    expect(v["value"],30);
    id = v["_id"];    
    return coll.findOne({"_id":id});
    }).chain((v){
    expect(v["value"],30);
    v["value"] = 1;    
    coll.save(v);    
    return coll.findOne({"_id":id});
  }).then((v1){    
    expect(v1["value"],1);    
    db.close();
    callbackDone();    
  });      
}

testCount(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){
    DbCollection coll = db.collection('testCount');
    coll.remove();
    for(int n=0;n<167;n++){
      coll.insert({"a":n});
        }    
    return coll.count();
  }).then((v){
    expect(v,167);
    db.close();
    callbackDone();
  });
}
testSkip(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){  
    DbCollection coll = db.collection('testSkip');
    coll.remove();
    for(int n=0;n<600;n++){
      coll.insert({"a":n});
        }    
    return coll.findOne(skip:300, orderBy: {"a":1});
  }).then((v){    
    expect(v["a"],300);
    db.close();
    callbackDone();
  });
}
testLimit(){
  Db db = new Db('mongo-dart-test');
  int counter = 0;
  Cursor cursor;
  db.open().chain((c){  
    DbCollection coll = db.collection('testLimit');
    coll.remove();
    for(int n=0;n<600;n++){
      coll.insert({"a":n});
    }    
    cursor = coll.find(skip:300, limit: 10, orderBy: {"a":1}); 
    return cursor.each((e)=>counter++);    
  }).then((v){    
    expect(counter,10);
    expect(cursor.state,Cursor.CLOSED);
    expect(cursor.cursorId,0);
    db.close();
    callbackDone();
  });
}

testCursorCreation(){
  Db db = new Db('mongo-dart-test');
  DbCollection collection = db.collection('student');
  Cursor cursor = new Cursor(db,collection);
}
testPingRaw(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){
    DbCollection collection = db.collection('\$cmd');
    Cursor cursor = new Cursor(db,collection,{"ping":1},limit:1);  
    MongoQueryMessage queryMessage = cursor.generateQueryMessage();
    Future mapFuture = db.connection.query(queryMessage);
    return mapFuture;
  }).then((msg) {
    expect({'ok': 1.0},recursivelyMatches(msg.documents[0]));
    db.close();
    callbackDone();
  });
}
testNextObject(){
  Db db = new Db('mongo-dart-test');
  db.open().chain((c){
    DbCollection collection = db.collection('\$cmd');
    Cursor cursor = new Cursor(db,collection,{"ping":1},limit:1);
    return cursor.nextObject();
  }).then((v){
    expect({'ok': 1.0},recursivelyMatches(v));
    db.close();
    callbackDone();
  });
}
testNextObjectToEnd(){
  var res;
  Db db = new Db('mongo-dart-test');
  Cursor cursor;
  db.open().chain((c){
    DbCollection collection = db.collection('testNextObjectToEnd');
    collection.remove();
    collection.insert({"a":1});
    collection.insert({"a":2});
    collection.insert({"a":3});
    cursor = new Cursor(db,collection,limit:10);  
    return cursor.nextObject();  
  }).then((v){
    expect(v,isNotNull);
    res = cursor.nextObject();
    res.then((v1){
      expect(v1,isNotNull);
      res = cursor.nextObject();
      res.then((v2){
        expect(v2,isNotNull);
        res = cursor.nextObject();
        res.then((v3){
          expect(v3,isNull);
          db.close();
          callbackDone();
        });  
      });  
    });  
  });  

}

testCursorWithOpenServerCursor(){  
  Db db = new Db('mongo-dart-test');
  Cursor cursor;
  db.open().chain((c){
    DbCollection collection = db.collection('new_big_collection');
    collection.remove();
    for (int n=0;n < 100; n++){
      collection.insert({"a":n});
    }
    cursor = new Cursor(db,collection,limit:10);  
    return cursor.nextObject();
  }).then((v){  
    expect(cursor.state, Cursor.OPEN);  
    expect(cursor.cursorId, isPositive);
    db.close();
    callbackDone();
    });
}
testCursorGetMore(){
  var res;
  Db db = new Db('mongo-dart-test');
  DbCollection collection;
  int count = 0;
  Cursor cursor;  
  db.open().chain((c){
    collection = db.collection('new_big_collection1');
    collection.remove();
    return db.getLastError();
  }).chain((dummy){
    List toInsert = new List();
    for (int n=0;n < 1000; n++){
      toInsert.add({"a":n});
    }
    collection.insertAll(toInsert);
    return db.getLastError();
  }).chain((_){
    cursor = new Cursor(db,collection,limit:10);  
    return cursor.each((v)=>count++);
  }).then((v){
    expect(1000, count);
    expect(0,cursor.cursorId);
    expect(Cursor.CLOSED,cursor.state);
    db.close();
    callbackDone();  
  });    
}
testCursorClosing(){
  var res;
  Db db = new Db('mongo-dart-test');
  DbCollection collection;
  Cursor cursor;
  db.open().chain((c){
    collection = db.collection('new_big_collection1');
    collection.remove();  
    for (int n=0;n < 1000; n++){  
      collection.insert({"a":n});
      }
    int count = 0;
    cursor = collection.find();
    expect(Cursor.INIT,cursor.state);
    return cursor.nextObject();
  }).then((v){    
    expect(Cursor.OPEN,cursor.state);
    expect(cursor.cursorId,isPositive);
    cursor.close();
    expect(Cursor.CLOSED,cursor.state);
    expect(0,cursor.cursorId);
    collection.findOne().then((v1){
      expect(v,isNotNull);
      db.close();
      callbackDone();  
    });
  });
}

testDbCommandCreation(){
  Db db = new Db('mongo-dart-test');
  DbCommand dbCommand = new DbCommand(db,"student",0,0,1,{},{});
  expect('mongo-dart-test.student',dbCommand.collectionNameBson.value);
}
testPingDbCommand(){
  Db db = new Db('mongo-dart-test');
  db.open().then((d){
    DbCommand pingCommand = DbCommand.createPingCommand(db);
    Future<MongoReplyMessage> mapFuture = db.executeQueryMessage(pingCommand);
    mapFuture.then((msg) {
      expect({'ok': 1},recursivelyMatches(msg.documents[0]));
      db.close();      
    });
  });
}
testDropDbCommand(){
  Db db = new Db('mongo-dart-test');
  db.open().then((d){
    DbCommand command = DbCommand.createDropDatabaseCommand(db);
    Future<MongoReplyMessage> mapFuture = db.executeQueryMessage(command);
    mapFuture.then((msg) {      
      expect(msg.documents[0]["ok"],1);      
      db.close();      
    });
  });
}
main(){
// some tests do not open db, when bson initialize
  initBsonPlatform(); 
  group("DbCollection tests:", (){
    test("testSelectorBuilderCreation",testSelectorBuilderCreation);
    test("testSelectorBuilderOnObjectId",testSelectorBuilderOnObjectId);    
  });
  group("DBCommand:", (){
    asyncTest("testDropDatabase",1,testDropDatabase);
    test("testDatabaseName",testDatabaseName);
    asyncTest("testCollectionInfoCursor",1,testCollectionInfoCursor);
    asyncTest("testRemove",1,testRemove);
    asyncTest("testGetNonce",1,testGetNonce);    
    asyncTest("testPwd",1,testPwd);        
  });  
  group("DbCollection tests:", (){
    asyncTest("testLimit",1,testLimit);
    asyncTest("testSkip",1,testSkip);    
    asyncTest("testFindEachWithThenClause",1,testFindEachWithThenClause);    
    asyncTest("testCount",1,testCount);    
    asyncTest("testFindEach",1,testFindEach);
    asyncTest("testDrop",1,testDrop);
    asyncTest("testSaveWithIntegerId",1,testSaveWithIntegerId);
    asyncTest("testSaveWithObjectId",1,testSaveWithObjectId);    
  }); 
  group("Cursor tests:", (){
    test("testCursorCreation",testCursorCreation);    
    asyncTest("testCursorClosing",1,testCursorClosing);
    asyncTest("testNextObjectToEnd",1,testNextObjectToEnd);    
    asyncTest("testPingRaw",1,testPingRaw);    
    asyncTest("testNextObject",1,testNextObject);    
    asyncTest("testCursorWithOpenServerCursor",1,testCursorWithOpenServerCursor);
    asyncTest("testCursorGetMore",1,testCursorGetMore);        
  });
  group("DBCommand tests:", (){
    test("testDbCommandCreation",testDbCommandCreation);
    test("testPingDbCommand",testPingDbCommand);
    test("testDropDbCommand",testDropDbCommand);    
  }); 
}