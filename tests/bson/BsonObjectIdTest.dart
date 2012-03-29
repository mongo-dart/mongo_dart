#library("BsonObjectId");
#import('../../third_party/testing/unittest/unittest_vm.dart');
#import("../../lib/bson/bson.dart");
testObjectId(){
  var id1 = new ObjectId();
  Expect.isNotNull(id1);
  id1 = new ObjectId();
  var id2 = new ObjectId();
  Expect.notEquals(id1,id2,"ObjectIds must be different albeit by increment");
  id1 = new ObjectId.fromSeconds(10);
  var leading8chars = id1.id.toHexString().substring(0,8);
  Expect.stringEquals("0000000a",leading8chars, 'Timestamp part of ObjectId must be encoded BigEndian');
}

main(){
  group("BsonObjectId:", (){
    test("testObjectId",testObjectId);    
  });
}
