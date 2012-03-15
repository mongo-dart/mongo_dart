#library("dbcommand");
#import("../lib/mongo.dart");
#import('../third_party/testing/unittest/unittest_vm.dart');
testDbCommandCreation(){
  Db db = new Db('test');
  DbCommand dbCommand = new DbCommand(db,"student",0,0,1,{},{});
  Expect.stringEquals('test.student',dbCommand.collectionNameBson.value);
}
testPingDbCommand(){
  Db db = new Db("test");
  db.open();
  DbCommand pingCommand = DbCommand.createPingCommand(db);
  Future<Map> mapFuture = db.executeQueryMessage(pingCommand);
  mapFuture.then((msg) {
    Expect.mapEquals({'ok': 1},msg.documents[0]);
    db.close();
  });
}

main(){
  group("DBCommand tests:", (){
    test("testDbCommandCreation",testDbCommandCreation);
    test("testPingDbCommand",testPingDbCommand);
  });
}