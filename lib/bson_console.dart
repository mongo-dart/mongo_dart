library bson_vm;
import 'bson.dart';
import 'dart:scalarlist';

class BsonPlatformVm extends BsonPlatform {

  dynamic makeUint8List(int size) => new Uint8List(size);
  makeByteArray(from) => from.asByteArray();
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformVm();
}

