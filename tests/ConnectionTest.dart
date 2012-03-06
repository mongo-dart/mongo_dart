#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:io");
testPing(){
  Connection conn = new Connection();
  conn.connect();
  MongoQueryMessage queryMessage = new MongoQueryMessage("db.\$cmd",0,0,1,{"ping":1},null);
  Future<Map> mapFuture = conn.query(queryMessage);
  mapFuture.then((msg) {
    Expect.mapEquals({'ok': 1.0},msg.documents[0]);
  });
}
testStudent(){
  Connection conn = new Connection();
  conn.connect();
  MongoQueryMessage queryMessage = new MongoQueryMessage("test.student",0,0,10,{},null);
  Future<Map> mapFuture = conn.query(queryMessage);
  mapFuture.then((msg) {
    for (var each in msg.documents){
      print(each);
    }      
  });
}

main(){
  testPing();
  testStudent();
}