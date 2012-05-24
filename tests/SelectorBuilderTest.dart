#library("HelperTest");
#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:io");
#import("dart:builtin");
#import('../../../dart/dart-sdk/lib/unittest/unittest.dart');
testSelectorBuilderCreation(){
  SelectorBuilder selector = query();
  expect(selector is Map && selector.isEmpty()).isTrue();
}
testSelectorBuilderOnObjectId(){
  ObjectId id = new ObjectId();
  SelectorBuilder selector = query().id(id);
  expect(selector is Map && selector.isEmpty()).isFalse();
}
main(){  
  group("DbCollection tests:", (){
    test("testSelectorBuilderCreation",testSelectorBuilderCreation);
    test("testSelectorBuilderOnObjectId",testSelectorBuilderOnObjectId);    
  });
}