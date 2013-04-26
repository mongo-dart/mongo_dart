library bson_vm;
import 'bson.dart';
import 'dart:typeddata';

class BsonPlatformVm extends BsonPlatform {

  dynamic makeUint8List(int size) => new Uint8List(size);
  ByteData makeByteArray(from) => new ByteData.view(from.buffer);
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformVm();
}

