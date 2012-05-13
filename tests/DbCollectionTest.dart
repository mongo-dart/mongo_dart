#library("mcollection");
#import("../lib/mongo.dart");
#import("dart:io");
#import("dart:builtin");
#import('../third_party/testing/unittest/unittest_vm.dart');
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
    expect(count).equals(3);
    expect(sum).equals(13);
    db.close();
    callbackDone();
   });
  
}
testDrop(){
  Db db = new Db('mongo-dart-test');
  db.open().then((v){
  db.dropCollection("testDrop").then((v)=>v);
  db.dropCollection("testDrop").then((v){    
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
  db.open().chain((c){
    DbCollection coll = db.collection('testCount');
    coll.remove();
    for(int n=0;n<167;n++){
      coll.insert({"a":n});
        }    
    return coll.count();
  }).then((v){
    expect(v).equals(167);
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
    expect(v["a"]).equals(300);
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
    expect(counter).equals(10);
    expect(cursor.state).equals(Cursor.CLOSED);
    expect(cursor.cursorId).equals(0);
    db.close();
    callbackDone();
  });
}

main(){
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
}