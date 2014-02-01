library all_tests;

import 'database_tests.dart' as database;
import 'gridfs_tests.dart' as gridfs;
import 'packet_converter_tests.dart' as converter;
import 'replica_tests.dart' as replica;

main(){
  converter.main();
  database.main();
  gridfs.main();
  replica.main();
}