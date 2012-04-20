#library("cursor_tests");
#import("../lib/mongo.dart");
#import("dart:io");
#import('dart:builtin');
#import('../third_party/testing/unittest/unittest_vm.dart');
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
    Expect.mapEquals({'ok': 1.0},msg.documents[0]);
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
    Expect.mapEquals({'ok': 1.0},v);
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
    expect(v).isNotNull();
    res = cursor.nextObject();
    res.then((v1){
      expect(v1).isNotNull();
      res = cursor.nextObject();
      res.then((v2){
        expect(v2).isNotNull();
        res = cursor.nextObject();
        res.then((v3){
          expect(v3).isNull();
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
    Expect.isTrue(cursor.state == Cursor.OPEN);  
    Expect.isTrue(cursor.cursorId > 0);
    db.close();
    callbackDone();
    });
}
testCursorGetMore(){
  var res;
  Db db = new Db('mongo-dart-test');
  DbCollection collection;
  db.open().chain((c){
    collection = db.collection('new_big_collection1');
    collection.remove();
    return db.getLastError();
  }).then((dummy){
    List toInsert = new List();
    for (int n=0;n < 1000; n++){
      toInsert.add({"a":n});
    }
    collection.insertAll(toInsert);  
    int count = 0;
    db.getLastError().then((dummy){
    Cursor cursor = new Cursor(db,collection,limit:10);  
      cursor.each((v){
            count++;
      }).then((v){
        Expect.equals(1000, count);
        Expect.equals(0,cursor.cursorId);
        Expect.equals(Cursor.CLOSED,cursor.state);
        db.close();
        callbackDone();
        });
      });
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
    expect(Cursor.INIT).equals(cursor.state);
    return cursor.nextObject();
  }).then((v){    
    expect(Cursor.OPEN).equals(cursor.state);
    expect(0 == cursor.cursorId).isFalse();
    cursor.close();
    expect(Cursor.CLOSED).equals(cursor.state);
    expect(0).equals(cursor.cursorId);
    collection.findOne().then((v1){
      expect(v).isNotNull();
      db.close();
      callbackDone();  
    });
  });
}

main(){
  group("Cursor tests:", (){
    test("testCursorCreation",testCursorCreation);    
    asyncTest("testCursorClosing",1,testCursorClosing);
    asyncTest("testNextObjectToEnd",1,testNextObjectToEnd);    
    asyncTest("testPingRaw",1,testPingRaw);    
    asyncTest("testNextObject",1,testNextObject);    
    asyncTest("testCursorWithOpenServerCursor",1,testCursorWithOpenServerCursor);
    asyncTest("testCursorGetMore",1,testCursorGetMore);
        
  });
}