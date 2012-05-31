#library("BsonTypesTest");
#import('../../third_party/unittest/unittest.dart');
#import("../../lib/bson/bson.dart");
typeTest(){
  Expect.isTrue(bsonObjectFrom(1234) is BsonInt);
  Expect.isTrue(bsonObjectFrom("asdfasdf") is BsonString);  
}
main(){
  group("BsonTypesTest:", (){
    test("typeTest",typeTest);
  });  
}