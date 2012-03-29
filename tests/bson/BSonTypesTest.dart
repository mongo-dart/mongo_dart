#library("BsonTypesTest");
#import('../../third_party/testing/unittest/unittest_vm.dart');
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