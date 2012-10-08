library tests;
import 'package:unittest/unittest.dart';
import 'dart:scalarlist';
import 'package:mongo_dart/bson.dart';

testUint8ListNegativeWrite(){
  Uint8List bl = new Uint8List(4);
  var ba = bl.asByteArray();
  ba.setInt32(0,-1);
  expect(bl,orderedEquals([255,255,255,255]));
}
testBinaryWithNegativeOne(){
  Binary b = new Binary(4);
  b.writeInt(-1);
  expect(b.hexString,'ffffffff');
}
testBinary(){
   Binary b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(1,4);
   expect('0000000001000000',b.hexString);
   b = new Binary(8);
   b.writeInt(0,4);
   b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(0x01020304,4);
   expect(b.hexString,'0000000004030201');
   b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(0x01020304,4,forceBigEndian:true);
   expect('0000000001020304',b.hexString);
   b = new Binary(8);
   b.writeInt(0,4);
   b.writeInt(1,4,forceBigEndian:true);
   expect('0000000000000001',b.hexString);
   b = new Binary(8);
   b.writeInt(1,3,forceBigEndian:true);
   expect('0000010000000000',b.hexString);
   b = new Binary(8);
   b.writeInt(0,3);
   b.writeInt(1,3,forceBigEndian:true);
   expect('0000000000010000',b.hexString);
   b = new Binary(4);
   b.writeInt(-1);
   expect(b.hexString,'ffffffff');
   b = new Binary(4);
   b.writeInt(-100);
   expect(b.hexString,'9cffffff');
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
  expect('15000000105f696400050000001061000400000000',buffer.hexString);
  buffer.offset = 0;
  Map root = bson.deserialize(buffer);
  expect(root['a'],4);
  expect(root['_id'],5);
//  expect(map,recursivelyMatches(root));
  var doc1 = {'a': [15]};
  buffer = bson.serialize(doc1);
  expect('140000000461000c0000001030000f0000000000',buffer.hexString);
  buffer.offset = 0;

  root = bson.deserialize(buffer);
  expect(15, root['a'][0]);
  doc1 = {'_id':5, 'a': [2,3,5]};
  buffer = bson.serialize(doc1);
  expect('2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',buffer.hexString);
  buffer.offset = 0;
  buffer.readByte();
  expect(1,buffer.offset);
  buffer.readInt32();
  expect(5,buffer.offset);
  buffer.offset = 0;
  root = bson.deserialize(buffer);
  expect(doc1['a'][2],root['a'][2], "doc1['a']");
}
testMakeByteList() {
  for (int n = 0; n<125; n++ ) {
    var hex = n.toRadixString(16);
    if (hex.length.remainder(2) != 0) {
      hex = '0$hex'; 
    }    
    var b = new Binary.fromHexString(hex);
    b.makeByteList();
    expect(b.byteList[0], n);
  }
  var b = new Binary.fromHexString('0301');
  b.makeByteList();
  expect(b.byteArray.getInt16(0), 259);
  b = new Binary.fromHexString('0301ad0c1ad34f1d');
  b.makeByteList();
  expect(b.hexString, '0301ad0c1ad34f1d');
  var oid1 = new ObjectId();
  var oid2 = new ObjectId.fromHexString(oid1.toHexString());
  oid2.id.makeByteList();
  expect(oid2.id.byteList,orderedEquals(oid1.id.byteList));
}

testBsonIdFromHexString() {
  var oid1 = new ObjectId();
  var oid2 = new ObjectId.fromHexString(oid1.toHexString());  
  oid2.id.makeByteList();
  expect(oid2.id.byteList,orderedEquals(oid1.id.byteList));
  var b1 = new BSON().serialize({'id':oid1});
  var b2 = new BSON().serialize({'id':oid2});
  b1.rewind();
  b2.rewind();
  var oid3 = new BSON().deserialize(b2)['id'];
  expect(oid3.id.byteList,orderedEquals(oid1.id.byteList));  
}
testBsonIdClientMode() {
  var oid1 = new ObjectId(clientMode: true);
  var oid2 = new ObjectId(clientMode: true);
  expect(oid2.toHexString().length, 24);
}
testBsonDbPointer() {
  var p1 = new DbRef('Test',new ObjectId());  
  var bson = new BSON();
  var b = bson.serialize({'p1': p1});
  b.rewind();
  var fromBson = bson.deserialize(b);  
  var p2 = fromBson['p1'];
  expect(p2.collection, p1.collection);
  expect(p2.id.toHexString(), p1.id.toHexString());
}


main(){
  group("BSonBinary:", (){
    test("testUint8ListNegativeWrite",testUint8ListNegativeWrite);
    test("testBinary",testBinary);
    test("testBinaryWithNegativeOne",testBinaryWithNegativeOne);
    test("testMakeByteList",testMakeByteList);    
  });
  group("BsonTypesTest:", (){
    test("typeTest",typeTest);
  });
  group("ObjectId:", (){
    test("testObjectId",testObjectId);
    test("testBsonIdFromHexString",testBsonIdFromHexString);
    test("testBsonIdClientMode",testBsonIdClientMode);
    test("testBsonDbPointer", testBsonDbPointer);
  });
  group("BsonSerialization:", (){    
    test("testSerializeDeserialize",testSerializeDeserialize);    
  });
}