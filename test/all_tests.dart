#library("all_tests");
#import("package:mongo_dart/bson.dart");
#import("bson_tests_vm.dart",prefix:"bson");
#import("json_ext_tests.dart",prefix:"json_ext");
#import("database_tests.dart",prefix:"database");

main(){
  bson.main();
  json_ext.main();
  database.main();
}