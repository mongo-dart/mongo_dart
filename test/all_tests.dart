#library("all_tests");
#import("package:mongo_dart/bson.dart");
#import("bson_tests_vm.dart",prefix:"bson");
#import("database_tests.dart",prefix:"database");
main(){
  bson.main();
  database.main();
}