#library("bson_browser");
#import("bson.dart");
#import("dart:html");

class BsonPlatformBrowser extends BsonPlatform {  
  List<int> makeUint8List(int size) => new Uint8Array(size);
  makeByteArray(List<int> from) => new DataView.fromBuffer(from.buffer);   
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformBrowser();
}

