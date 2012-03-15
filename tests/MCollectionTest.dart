#library("mcollection");
#import("../lib/mongo.dart");
#import("dart:io");
#import("dart:builtin");
#import('../third_party/testing/unittest/unittest_vm.dart');
testCollectionCreation(){
  Db db = new Db('db');
  MCollection collection = db.collection('student');
}
testEach(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection newColl = db.collection('newColl1');
  int count = 0;
  int sum = 0;
  newColl.find().each((v)
    {sum += v["a"]; count++;
  }).then((v)=>print("Completed. Sum = $sum, count = $count"));
}
testFindEachWithThenClause(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection students = db.collection('students');
  students.drop();
  students.insertAll(
    [
     {"name":"Vadim","score":4},
     {"name": "Daniil","score":4},
     {"name": "Nick", "score": 5}
    ]
  );
  int count = 0;
  int sum = 0;
  students.find().each((v)
    {sum += v["score"]; count++;
  }).then((v){
    print("Students Completed. Sum = $sum, count = $count average score = ${sum/count}");    
    db.close();
  });
}
testFindEach(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection students = db.collection('students');
  students.remove();
  students.insertAll(
    [
     {"name":"Vadim","score":4},
     {"name": "Daniil","score":4},
     {"name": "Nick", "score": 5}
    ]
  );
  db.getLastError().then((v){   
  int count = 0;
  int sum = 0;
  students.find().each((v){
    count++;
    sum += v["score"];
  }).then((v){
    new Expectation(count).equals(3);
    new Expectation(sum).equals(13);
//    new Expectation(count).equals(0);
    db.close();
    callbackDone();
   });
  });
}
testDrop(){
  Db db = new Db('mongo-dart-test');
  db.open();
  db.dropCollection("students").then((v)=>v);
  db.dropCollection("students").then((v){
    db.close();
  });  
}  

testSaveWithIntegerId(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection coll = db.collection('collection-for-save');
  coll.remove();
  var id;
  List toInsert = [
                   {"_id":1,"name":"a", "value": 10},
                   {"_id":2,"name":"b", "value": 20},
                   {"_id":3,"name":"c", "value": 30},
                   {"_id":4,"name":"d", "value": 40}
                 ];
  coll.insertAll(toInsert);
  coll.findOne({"name":"c"}).chain((v){  
    new Expectation(v["value"]).equals(30);    
    return coll.findOne({"_id":3});
    }).chain((v){  
    v["value"] = 31;    
    coll.save(v);
    return coll.findOne({"_id":3});
  }).then((v1){
    new Expectation(v1["value"]).equals(31);    
    db.close();
  });      
}
testSaveWithObjectId(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection coll = db.collection('collection-for-save');
  coll.remove();
  var id;
  List toInsert = [
                   {"name":"a", "value": 10},
                   {"name":"b", "value": 20},
                   {"name":"c", "value": 30},
                   {"name":"d", "value": 40}
                 ];
  coll.insertAll(toInsert);
  coll.findOne({"name":"c"}).chain((v){  
    new Expectation(v["value"]).equals(30);
    id = v["_id"]; 
    return coll.findOne({"_id":id});
    }).chain((v){
    new Expectation(v["value"]).equals(30);
    v["value"] = 31;    
    coll.save(v);
    return coll.findOne({"_id":id});
  }).then((v1){
    new Expectation(v1["value"]).equals(31);    
    db.close();
  });      
}


main(){  
  group("MCollection tests:", (){
//    asyncTest("testFindEach",1,testFindEach);
//    test("testDrop",testDrop);
//    test("testSaveWithIntegerId",testSaveWithIntegerId);
    test("testSaveWithObjectId",testSaveWithObjectId());    
  });
}