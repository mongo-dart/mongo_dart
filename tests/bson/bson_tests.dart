#library("tests");
#import('../../third_party/unittest/unittest.dart');
#import("../../lib/bson/bson.dart");

testUint8ListNegativeWrite(){
  Uint8List bl = new Uint8List(4);
  ByteArray ba = bl.asByteArray();
  ba.setInt32(0,-1);
  expect(bl,recursivelyMatches([255,255,255,255]));
}
testBinaryWithNegativeOne(){
  Binary b = new Binary(4);
  b.writeInt(-1);   
  expect(b.toHexString(),'ffffffff');  
}
testBinary(){
   Binary b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(1,4);
   expect('0000000001000000',b.toHexString());   
   b = new Binary(8);
   b.writeInt(0,4);
   b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(0x01020304,4);
   expect(b.toHexString(),'0000000004030201');
   b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(0x01020304,4,forceBigEndian:true);
   expect('0000000001020304',b.toHexString());
   b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(1,4,forceBigEndian:true);   
   expect('0000000000000001',b.toHexString());   
   b = new Binary(8);   
   b.writeInt(1,3,forceBigEndian:true);
   expect('0000010000000000',b.toHexString());
   b = new Binary(8);
   b.writeInt(0,3);
   b.writeInt(1,3,forceBigEndian:true);
   expect('0000000000010000',b.toHexString());
   b = new Binary(4);
   b.writeInt(-1);   
   expect(b.toHexString(),'ffffffff');
   b = new Binary(4);
   b.writeInt(-100);   
   expect(b.toHexString(),'9cffffff');   
}

typeTest(){
  expect(bsonObjectFrom(1234) is BsonInt);
  expect(bsonObjectFrom("asdfasdf") is BsonString);
  expect(bsonObjectFrom(new Date.now()) is BsonDate);
  expect(bsonObjectFrom([2,3,4]) is BsonArray);
}

testObjectId(){
  var id1 = new ObjectId();
  expect(id1,isNotNull);
  id1 = new ObjectId();
  var id2 = new ObjectId();
  expect(id1,isNot(id2),"ObjectIds must be different albeit by increment");
  id1 = new ObjectId.fromSeconds(10);
  var leading8chars = id1.toHexString().substring(0,8);
  expect("0000000a",leading8chars, 'Timestamp part of ObjectId must be encoded BigEndian');
}

testSerializeDeserialize(){
  var bson = new BSON();
  var map = {'_id':5, 'a':4};
  Binary buffer = bson.serialize(map);
  expect('15000000105f696400050000001061000400000000',buffer.toHexString());
  buffer.offset = 0;
  Map root = bson.deserialize(buffer);    
  expect(root['a'],4);
  expect(root['_id'],5);
  expect(map,recursivelyMatches(root));
  var doc1 = {'a': [15]};
  buffer = bson.serialize(doc1);
  expect('140000000461000c0000001030000f0000000000',buffer.toHexString());
  buffer.offset = 0;
  
  root = bson.deserialize(buffer);  
  expect(15, root['a'][0]);
  doc1 = {'_id':5, 'a': [2,3,5]};    
  buffer = bson.serialize(doc1);
  expect('2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',buffer.toHexString());
  buffer.offset = 0;
  buffer.readByte();
  expect(1,buffer.offset);
  buffer.readInt32();
  expect(5,buffer.offset);
  buffer.offset = 0;
  root = bson.deserialize(buffer);  
  expect(doc1['a'][2],root['a'][2], "doc1['a']");
}

main(){
  group("BSonBinary:", (){
    test("testUint8ListNegativeWrite",testUint8ListNegativeWrite);
    test("testBinary",testBinary);
    test("testBinaryWithNegativeOne",testBinaryWithNegativeOne);    
  });
  group("BsonTypesTest:", (){
    test("typeTest",typeTest);
  });
  group("BsonObjectId:", (){
    test("testObjectId",testObjectId);    
  });
  group("BsonSerialization:", (){
    test("testSerializeDeserialize",testSerializeDeserialize);  
  });  
}