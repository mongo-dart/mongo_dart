library bson_vm;
import 'package:mongo_dart/bson.dart';
import 'dart:scalarlist';

class BsonPlatformVm extends BsonPlatform {

  Dynamic makeUint8List(int size) => new Uint8List(size);
  makeByteArray(from) => from.asByteArray();
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformVm();  
}

