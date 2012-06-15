#library("bson_tests_vm");
#import("../../lib/bson/bson_vm.dart");
#import("bson_tests.dart",prefix:"tests");
main(){
  initBsonPlatform();
  tests.main();  
}