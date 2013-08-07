library all_tests;

import 'database_tests.dart' as database;
import 'gridfs_tests.dart' as gridfs;
import 'packet_converter_tests.dart' as converter;

main(){
  converter.main();
  database.main();
  gridfs.main();
}