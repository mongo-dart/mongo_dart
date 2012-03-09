#import("../lib/mongo.dart");
#import("dart:io");
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
testFindEach(){
  Db db = new Db('test');
  db.open();  
  MCollection newColl = db.collection('newColl1');
  int count = 0;
  int sum = 0;
  newColl.find().each((v)
    {sum += v["a"]; count++;
  }).then((v)=>print("Completed. Sum = $sum, count = $count"));
}
testFindEachStudent(){
  Db db = new Db('test');
  db.open();  
  MCollection newColl = db.collection('student');
  int count = 0;
  int sum = 0;
  newColl.find().each((v)
    {sum += v["score"]; count++;
  }).then((v)=>print("Students Completed. Sum = $sum, count = $count"));
}

main(){
  testFindEach();
  testFindEachStudent();
/*  testCollectionCreation();
  testSave();
  testSaveAll();  
*/  
}