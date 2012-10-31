library bson_tests_vm;
import 'package:mongo_dart/mongo_dart.dart';
import 'bson_tests.dart' as tests;
main(){
  initBsonPlatform();
  tests.runMe();
}