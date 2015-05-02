library all_tests;

import 'database_test.dart' as database;
import 'gridfs_test.dart' as gridfs;
import 'packet_converter_test.dart' as converter;
import 'mongo_dart_query_test.dart' as mongo_dart_query;
//import 'replica_tests.dart' as replica;

main(){
  converter.main();
  database.main();
  gridfs.main();
  mongo_dart_query.main();
  //replica.main();
}