#library("dbtest");
#import("../lib/mongo.dart");
#import('dart:builtin');
#import('../third_party/testing/unittest/unittest_vm.dart');
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
    Expect.isTrue(v.length == 1);
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
    Expect.isTrue(v.length == 1);
    db.removeFromCollection("new_collecion_to_remove");
    //db.getLastError().then((v)=>print("remove result: $v"));
    newColl.find().toList().then((v1){
      Expect.isTrue(v1.isEmpty());
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
      print(v);
      Expect.isTrue(v["ok"] == 1);
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

main(){
  group("DBCommand:", (){
    asyncTest("testDropDatabase",1,testDropDatabase);
    test("testDatabaseName",testDatabaseName);
    asyncTest("testCollectionInfoCursor",1,testCollectionInfoCursor);
    asyncTest("testRemove",1,testRemove);
    asyncTest("testGetNonce",1,testGetNonce);    
    asyncTest("testPwd",1,testPwd);        
  });  
  
}