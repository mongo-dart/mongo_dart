library all_tests;

import 'database_test.dart' as database;
import 'gridfs_test.dart' as gridfs;
import 'packet_converter_test.dart' as converter;
import 'mongo_dart_query_test.dart' as mongo_dart_query;
import 'authentication_test.dart' as auth_tests;
import 'ssl_connection_test.dart' as ssl_tests;
import 'utils_test.dart' as utils_tests;

//import 'replica_tests.dart' as replica;

void main() {
  converter.main();
  database.main();
  gridfs.main();
  mongo_dart_query.main();
  auth_tests.main();
  ssl_tests.main();
  utils_tests.main();
  //replica.main();
}
