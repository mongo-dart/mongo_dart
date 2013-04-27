library all_tests;
import 'package:bson/bson.dart';
import 'database_tests.dart' as database;
import 'gridfs_tests.dart' as gridfs;

main(){
  database.main();
  gridfs.main();
}