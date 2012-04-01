#library("mcollection");
#import("../lib/mongo.dart");
#import("dart:io");
#import("dart:builtin");
#import('../third_party/testing/unittest/unittest_vm.dart');
testSelectorBuilderCreation(){
  SelectorBuilder selector = where();
  expect(selector is Map && selector.isEmpty()).isTrue();
}

main(){  
  group("DbCollection tests:", (){
    test("testSelectorBuilderCreation",testSelectorBuilderCreation);
  });
}