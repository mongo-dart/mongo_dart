part of bson;

List<int> makeUint8List(int size) => BsonPlatform.platform.makeUint8List(size);
makeByteArray(List<int> from) => BsonPlatform.platform.makeByteArray(from);

abstract class BsonPlatform {
  static BsonPlatform platform;
  dynamic makeUint8List(int size);
  dynamic makeByteArray(List<int> from);
}
