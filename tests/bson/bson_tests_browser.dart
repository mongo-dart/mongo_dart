#import('dart:html');
#import('../../third_party/unittest/unittest.dart');
#import("../../lib/bson/bson.dart");
#import("../../lib/bson/bson_browser.dart");
#import("bson_tests.dart",prefix:"tests");
main(){
  initBsonPlatform();  
  tests.main();  
}
void show(String message) {
  query('#status').text = message;
}
