#library("bsonimpltest");
#import('../../third_party/testing/unittest/unittest_vm.dart');
#import("../../lib/bson/bson.dart");
testSerializeDeserialize(){
  var bson = new BSON();
  var map = {'_id':5, 'a':4};
  Binary buffer = bson.serialize(map);
  Expect.stringEquals('15000000105f696400050000001061000400000000',buffer.toHexString());
  buffer.offset = 0;
  Map root = bson.deserialize(buffer);    
  Expect.equals(root['a'],4);
  Expect.equals(root['_id'],5);
  Expect.mapEquals(map,root);
  var doc1 = {'a': [15]};
  buffer = bson.serialize(doc1);
  Expect.stringEquals('140000000461000c0000001030000f0000000000',buffer.toHexString());
  buffer.offset = 0;
  root = bson.deserialize(buffer);  
  Expect.equals(15, root['a'][0]);
  doc1 = {'_id':5, 'a': [2,3,5]};    
  buffer = bson.serialize(doc1);
  Expect.stringEquals('2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',buffer.toHexString());
  buffer.offset = 0;
  buffer.readByte();
  Expect.equals(1,buffer.offset);
  buffer.readInt32();
  Expect.equals(5,buffer.offset);
  buffer.offset = 0;
  root = bson.deserialize(buffer);  
  Expect.equals(doc1['a'][2],root['a'][2], "doc1['a']");
}
main(){
  group("BsonImpl:", (){
    test("testSerializeDeserialize",testSerializeDeserialize);    
  });
}