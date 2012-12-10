part of bson;

List<int> makeUint8List(int size) => BsonPlatform.platform.makeUint8List(size);
makeByteArray(List<int> from) => BsonPlatform.platform.makeByteArray(from);

abstract class BsonPlatform {
  static BsonPlatform platform;
  dynamic makeUint8List(int size);
  dynamic makeByteArray(List<int> from);
}


abstract class BsonByteArray {
  int getInt8(int byteOffset);

  void setInt8(int byteOffset, int value);

  int getUint8(int byteOffset);

  void setUint8(int byteOffset, int value);

  int getInt16(int byteOffset);

  void setInt16(int byteOffset, int value);

  int getUint16(int byteOffset);

  void setUint16(int byteOffset, int value);

  int getInt32(int byteOffset);

  void setInt32(int byteOffset, int value);

  int getUint32(int byteOffset);

  void setUint32(int byteOffset, int value);

  int getInt64(int byteOffset);

  void setInt64(int byteOffset, int value);

  int getUint64(int byteOffset);

  void setUint64(int byteOffset, int value);

  double getFloat32(int byteOffset);

  void setFloat32(int byteOffset, double value);

  double getFloat64(int byteOffset);

  void setFloat64(int byteOffset, double value);
}
