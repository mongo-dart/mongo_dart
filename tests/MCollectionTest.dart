#import("../lib/mongo.dart");
#import("dart:io");
testCollectionCreation(){
  Db db = new Db('db');
  MCollection collection = db.collection('student');
}
testInsertCommand(){
  Db db = new Db('test');
  db.open();
  MCollection newColl; 
/*  newColl = db.collection('newColl');  
  print(newColl.fullName());
  List<Map> docsToInsert  = new List();
  for (int i = 0; i < 200; i++){
    docsToInsert.add({"a":i});
  }
  newColl.save(docsToInsert);
*/  
  newColl = db.collection('newColl1');  
  print(newColl.fullName());
  for (int i = 0; i < 5000; i++){
    newColl.save([{"a":i}]);
  }
}
main(){
  testCollectionCreation();
  testInsertCommand();
}