library bson_tests_vm;
import 'package:mongo_dart/bson_vm.dart';
import 'bson_tests.dart' as tests;
main(){
  initBsonPlatform();   
  tests.main();  
}