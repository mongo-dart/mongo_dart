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
  }).then((v)=>info("Completed. Sum = $sum, count = $count"));
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
    info("Students Completed. Sum = $sum, count = $count average score = ${sum/count}");    
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
  int count = 0;
  int sum = 0;
  students.find().each((v1){
    count++;
    sum += v1["score"];
  }).then((v){
    expect(count).equals(3);
    expect(sum).equals(13);
    db.close();
    callbackDone();
   });
  
}
testDrop(){
  Db db = new Db('mongo-dart-test');
  db.open();
  db.dropCollection("testDrop").then((v)=>v);
  db.dropCollection("testDrop").then((v){
    db.close();
    callbackDone();    
  });  
}  

testSaveWithIntegerId(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection coll = db.collection('testSaveWithIntegerId');
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
    expect(v["value"]).equals(30);    
    return coll.findOne({"_id":3});
    }).chain((v){  
    v["value"] = 2;    
    coll.save(v);
    return coll.findOne({"_id":3});
  }).then((v1){
    expect(v1["value"]).equals(2);    
    db.close();
    callbackDone();
  });      
}
testSaveWithObjectId(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection coll = db.collection('testSaveWithObjectId');
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
    v["value"] = 1;    
    coll.save(v);    
    return coll.findOne({"_id":id});
  }).then((v1){    
    new Expectation(v1["value"]).equals(1);    
    db.close();
    callbackDone();    
  });      
}

testCount(){
  Db db = new Db('mongo-dart-test');
  db.open();  
  MCollection coll = db.collection('testCount');
  coll.remove();
  for(int n=0;n<1067;n++){
    coll.insert({"a":n});
  }    
  coll.count().then((v){
    expect(v).equals(1067);
    db.close();
  });
}


runAll([bool asTestSuite = false]){
  if (asTestSuite){
    group("MCollection tests:", (){
      asyncTest("testFindEach",1,testFindEach);
      asyncTest("testDrop",1,testDrop);
      asyncTest("testSaveWithIntegerId",1,testSaveWithIntegerId);
      asyncTest("testSaveWithObjectId",1,testSaveWithObjectId);    
    });
  }
  else{
    testFindEach();    
    testDrop();
    testSaveWithIntegerId();
    testSaveWithObjectId();
  }
    
}
main(){
  setVerboseState();
  testCount();
  return;
  group("MCollection tests:", (){
    asyncTest("testCount",1,testCount);    
    asyncTest("testFindEach",1,testFindEach);
    asyncTest("testDrop",1,testDrop);
    asyncTest("testSaveWithIntegerId",1,testSaveWithIntegerId);
    asyncTest("testSaveWithObjectId",1,testSaveWithObjectId);    
  });
}