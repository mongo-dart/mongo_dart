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
  db.open();
  MCollection newColl = db.collection("new_collecion");
  newColl.drop();
  newColl.insertAll([{"a":1}]);
  bool found = false;
  db.collectionsInfoCursor("new_collecion").toList().then((v){
    Expect.isTrue(v.length == 1);
//    newColl.drop();
    db.close();
    callbackDone();
  });
}
testRemove(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  db.removeFromCollection("new_collecion_to_remove");
  MCollection newColl = db.collection("new_collecion_to_remove");  
  newColl.insertAll([{"a":1}]);
  db.collectionsInfoCursor("new_collecion_to_remove").toList().then((v){    
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
  db.open();
  db.drop().then((v){
    print(v);
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
  });  
  
}