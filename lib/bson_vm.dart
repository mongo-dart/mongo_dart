library bson_vm;
import 'bson.dart';
import 'src/bson/json_ext.dart';
import 'dart:scalarlist';


export 'bson.dart';
export 'src/bson/json_ext.dart';

class BsonPlatformVm extends BsonPlatform {

  Dynamic makeUint8List(int size) => new Uint8List(size);
  makeByteArray(from) => from.asByteArray();
}

initBsonPlatform() {
  BsonPlatform.platform = new BsonPlatformVm();  
}

