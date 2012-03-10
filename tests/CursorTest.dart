#import("../lib/mongo.dart");
#import("dart:io");
#import('dart:builtin'); 
testCursorCreation(){
  Db db = new Db('db');
  MCollection collection = db.collection('student');
  Cursor cursor = new Cursor(db,collection);
}
testPingRaw(){
  Db db = new Db('db');
  db.open();
  MCollection collection = db.collection('\$cmd');
  Cursor cursor = new Cursor(db,collection,{"ping":1},limit:1);  
  MongoQueryMessage queryMessage = cursor.generateQueryMessage();
  Future mapFuture = db.connection.query(queryMessage);
  mapFuture.then((msg) {
//    print(msg.documents);
    Expect.mapEquals({'ok': 1.0},msg.documents[0]);
    db.close();
  });
}
testNextObject(){
  Db db = new Db('db');
  db.open();
  MCollection collection = db.collection('\$cmd');
  Cursor cursor = new Cursor(db,collection,{"ping":1},limit:1);
  var res = cursor.nextObject();
  res.then((v){
//    print(v);
    Expect.mapEquals({'ok': 1.0},v);
  });
}
testNextObjectToEnd(){
  var res;
  Db db = new Db('test');
  db.open();
  MCollection collection = db.collection('student');
  Cursor cursor = new Cursor(db,collection,limit:10);  
  res = cursor.nextObject();  
  res.then((v){
//    print(v);    
    res = cursor.nextObject();
    res.then((v){
//      print(v);    
      res = cursor.nextObject();
      res.then((v){
//        print(v);
        res = cursor.nextObject();
        res.then((v){
//          print(v);    
        });  
      });  
    });  
  });  

}

testEach(){
  var res;
  int sumScore = 0;
  int count = 0;
  var futures = new List();
  Db db = new Db('test');
  db.open();
  
  MCollection collection = db.collection('student');  
  //collection.drop().chain((v){
/*  new Future.immediate(true).chain((v){    
  print("there");  
  return db.getLastError();}).then((v){
  print("here");
  collection.saveAll([{"name":"Daniil","score":4},{"name":"Nick","score":5}]);
  db.getLastError().then((m)
  {
    print(m);
  });
  });  
*/
collection.saveAll([{"name":"Daniil","score":4},{"name":"Nick","score":5}]);
  db.getLastError().then((m)
  {
    print(m);
    print(db.connection.sendQueue);
  });
  
/*  MCollection newColl = db.collection('student');

  int sum = 0;
  newColl.find().each((v)
    { count++; print(v);
  }).then((v)=>print("Completed. Sum = $sum, count = $count"));

*/  

/*  
  collection.save({"name":"Daniil","score":4}).then((v)=>print(v));
  collection.save({"name":"Nick","score":5}).then((v)=>print(v));   
*/
/*
  new Timer((timer){
      Cursor cursor = new Cursor(db,collection,limit:50);  
      cursor.each((e){
          print(e);//;count++;sumScore += e["score"];
      }).then((v){
      Expect.isTrue(v);
      Expect.isTrue(cursor.state == Cursor.CLOSED);
//      Expect.equals((4+4+5)/3, sumScore/count);
      print("CursorId = ${cursor.cursorId}");    
      
  });        
}, 0);
*/
/*  var f = Futures.wait(futures);
  print(f);
  f.then((v){ 
      print("there");
      Cursor cursor = new Cursor(db,collection,limit:10);  
      cursor.each((e){
          print(e);count++;sumScore += v["score"];
      }).then((v){
      Expect.isTrue(v);
      Expect.isTrue(cursor.state == Cursor.CLOSED);
      Expect.equals((4+4+5)/3, sumScore/count);
      print("CursorId = ${cursor.cursorId}");    
      
  });  
*/  
}
testCursorWithOpenServerCursor(){
  var res;
  Db db = new Db('test');
  db.open();
  MCollection collection = db.collection('new_big_collection');
  collection.remove();
  for (int n=0;n < 1000; n++){
    collection.insert({"a":n});
  }
  Cursor cursor = new Cursor(db,collection,limit:10);  
  cursor.nextObject().then((v){
    print(v);
    Expect.isTrue(cursor.state == Cursor.OPEN);
    print("CursorId = ${cursor.cursorId}");
    Expect.isTrue(cursor.cursorId > 0);
    db.close();
    });
}
testCursorGetMore(){
  var res;
  Db db = new Db('test');
  db.open();
  MCollection collection = db.collection('new_big_collection');
  collection.remove();
  for (int n=0;n < 1000; n++){
    collection.insert({"a":n});
  }
  int count = 0;
  Cursor cursor = new Cursor(db,collection,limit:10);  
  cursor.each((v)=>count++).then((v){
    print(count);
    Expect.equals(1000, count);
    Expect.equals(0,cursor.cursorId);
    Expect.equals(Cursor.CLOSED,cursor.state);
    db.close();
    });
}

main(){
  testCursorCreation();
  testPingRaw();
  testCursorWithOpenServerCursor();
  testCursorGetMore();
//  testNextObject();
//  testNextObjectToEnd();
//  testEach();
//  testEachWithGetMore();
}