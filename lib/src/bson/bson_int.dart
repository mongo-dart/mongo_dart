part of bson;
class BsonInt extends BsonObject{
  int data;
  BsonInt(this.data);
  get value=>data;
  byteLength()=>4;
  int get typeByte => BSON.BSON_DATA_INT;
  packValue(Binary buffer){
     buffer.writeInt(data);
  }
  unpackValue(Binary buffer){
     data = buffer.readInt32();
  }
}

class BsonLong extends BsonObject{
  int data;
  BsonLong(this.data);
  get value=>data;
  byteLength()=>8;
  int get typeByte => BSON.BSON_DATA_LONG;
  packValue(Binary buffer){
    buffer.writeInt64(data);
  }
  unpackValue(Binary buffer){
    data = buffer.readInt64();
  }
}
