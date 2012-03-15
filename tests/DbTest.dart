#library("dbtest");
#import("../lib/mongo.dart");
#import('dart:builtin');
#import('../third_party/testing/unittest/unittest_vm.dart');
testDatabaseName(){
  Db db = new Db('db');
  String dbName;
  dbName = 'db';
  db.validateDatabaseName(dbName);
  dbName = 'db';
  db.validateDatabaseName(dbName);  
}
testCollectionInfoCursor(){
  Db db = new Db('test');
  db.open();
  MCollection newColl = db.collection("new_collecion");
  newColl.drop();
  newColl.insertAll([{"a":1}]);
  bool found = false;
  db.collectionsInfoCursor("new_collecion").toList().then((v){
    Expect.isTrue(v.length == 1);
//    newColl.drop();
    db.close();
  });
}
testRemove(){
  Db db = new Db('test');
  db.open();  
  db.removeFromCollection("new_collecion_to_remove");
  MCollection newColl = db.collection("new_collecion_to_remove");  
  newColl.insertAll([{"a":1}]);
  db.collectionsInfoCursor("new_collecion_to_remove").toList().then((v){    
    Expect.isTrue(v.length == 1);
    db.removeFromCollection("new_collecion_to_remove");
    //db.getLastError().then((v)=>print("remove result: $v"));
    newColl.find().toList().then((v){
      Expect.isTrue(v.isEmpty());
      newColl.drop();
      db.close();
   });
  });
}

main(){
  group("DBCommand tests:", (){
    test("testDatabaseName",testDatabaseName);
    test("testCollectionInfoCursor",testCollectionInfoCursor);
    test("testRemove",testRemove);
  });  
  
}