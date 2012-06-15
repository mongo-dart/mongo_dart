#library("bson_vm");
#import("bson.dart");

class BsonPlatformVm extends BsonPlatform {
  
  List<int> makeUint8List(int size) => new Uint8List(size);
  makeByteArray(List<int> from) => from.asByteArray();
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformVm();
}

