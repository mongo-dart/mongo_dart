#library("HelperTest");
#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:io");
#import("dart:builtin");
#import('../third_party/testing/unittest/unittest_vm.dart');
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