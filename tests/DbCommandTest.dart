#import("../lib/mongo.dart");
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
  });
}
testDropCollectionCommand(){
  Db db = new Db("test");
  db.open();
//  print(isFutureThrowsException(db.dropCollection("collection_with_that_name_does_not_exists")));
//  db.dropCollection("newColl");
//  db.collection("student").drop().then((v)=>print("Student collection dropped"));
}

isFutureThrowsException(Future future){
  bool result = false;  
  future.handleException((ex){
    result = true;
    return true;
  });
  future.then((v) => v);
  return result;
}

main(){
  testDbCommandCreation();  
  testPingDbCommand();
  testDropCollectionCommand();
}