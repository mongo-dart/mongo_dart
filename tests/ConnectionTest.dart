#library("connection_test");
#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:io");
#import('dart:builtin');
#import('../third_party/testing/unittest/unittest_vm.dart');
testPing(){
  Connection conn = new Connection();
  conn.connect();
  MongoQueryMessage queryMessage = new MongoQueryMessage("db.\$cmd",0,0,1,{"ping":1},null);
  var replyFuture = conn.query(queryMessage);
  replyFuture.then((msg) {
    Expect.mapEquals({'ok': 1.0},msg.documents[0]);
    conn.close();    
  });
}
testStudent(){
  Connection conn = new Connection();
  conn.connect();
  MongoQueryMessage queryMessage = new MongoQueryMessage("test.student",0,0,10,{"name":"Daniil"},null);
  Future<MongoReplyMessage> replyFuture = conn.query(queryMessage);
  replyFuture.then((msg) {
    for (var each in msg.documents){
    }
    conn.close();
  });
}
testGetMore(){

}
main(){
  group("Connection tests:", (){
    test("Test ping",testPing);
    test("Test testStudent",testStudent);
  });
}