#import("../lib/mongo.dart");
#import("dart:io");
#import("dart:builtin");
testCollectionCreation(){
  Db db = new Db('db');
  MCollection collection = db.collection('student');
}
testSaveAll(){
  Db db = new Db('test');
  db.open();
  MCollection newColl; 
  newColl = db.collection('newColl');  
  print(newColl.fullName());
  List<Map> docsToInsert  = new List();
  for (int i = 0; i < 200; i++){
    docsToInsert.add({"a":i});
  }
  newColl.saveAll(docsToInsert);
}
testSave(){
  Db db = new Db('test');
  db.open();  
  MCollection newColl = db.collection('newColl1');  
  print(newColl.fullName());
  for (int i = 0; i < 5000; i++){
    newColl.save({"a":i});
  }
}
testEach(){
  Db db = new Db('test');
  db.open();  
  MCollection newColl = db.collection('newColl1');
  int count = 0;
  int sum = 0;
  newColl.find().each((v)
    {sum += v["a"]; count++;
  }).then((v)=>print("Completed. Sum = $sum, count = $count"));
}
testFindEachWithThenClause(){
  Db db = new Db('test');
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
  Db db = new Db('test');
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
  db.getLastError().then((v){
  print(v);
  print("there");  
  int count = 0;
  int sum = 0;
  students.find().each((v) => print("student: $v")).then((v){
    db.close();
   });
  });
}
testDrop(){
  Db db = new Db('test');
  db.open();
  db.dropCollection("students").then((v)=>print("deleted"));
  db.dropCollection("students").then((v){
    db.close();
  });  
}
main(){
  //testFindEachWithThenClause();
  testDrop();
  testFindEach();
//  testDrop();
/*  
  testFindEach();
  testFindEachStudent();
  testCollectionCreation();
  testSave();
  testSaveAll();  
*/  
}