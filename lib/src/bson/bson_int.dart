part of bson;
class BsonInt extends BsonObject{
  int data;
  BsonInt(this.data);
  get value=>data;
  byteLength()=>4;
  int get typeByte => BSON.BSON_DATA_INT;
  packValue(BsonBinary buffer){
     buffer.writeInt(data);
  }
  unpackValue(BsonBinary buffer){
     data = buffer.readInt32();
  }
}

class BsonLong extends BsonObject{
  int data;
  BsonLong(this.data);
  get value=>data;
  byteLength()=>8;
  int get typeByte => BSON.BSON_DATA_LONG;
  packValue(BsonBinary buffer){
    buffer.writeInt64(data);
  }
  unpackValue(BsonBinary buffer){
    data = buffer.readInt64();
  }
}
