#library("bson_browser");
#import("bson.dart");
#import("dart:html");

class BsonPlatformBrowser extends BsonPlatform {  
  List<int> makeUint8List(int size) => new Uint8Array(size);
  makeByteArray(from) => new DataView(from.buffer);   
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformBrowser();
}

