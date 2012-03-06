#import("../lib/mongo.dart");
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
  Connection conn = new Connection();
  conn.connect();  
  MongoQueryMessage queryMessage = cursor.generateQueryMessage();
  Future<Map> mapFuture = conn.query(queryMessage);
  mapFuture.then((msg) {
 //   print(msg.documents);
    Expect.mapEquals({'ok': 1.0},msg.documents[0]);
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
  Db db = new Db('test');
  db.open();
  MCollection collection = db.collection('student');
  Cursor cursor = new Cursor(db,collection,limit:10);  
  cursor.each((v) => print(v)).then((v){
    Expect.isTrue(v);
    Expect.isTrue(cursor.state == Cursor.CLOSED);
    });
  Expect.isTrue(cursor.state == Cursor.INIT);
}

main(){
  testCursorCreation();
  testPingRaw();
  testNextObject();
  testNextObjectToEnd();
  testEach();
}