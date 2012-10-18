part of bson;
class BsonDouble extends BsonObject{
  double data;
  BsonDouble(this.data);
  get value=>data;
  byteLength()=>8;
  int get typeByte => BSON.BSON_DATA_NUMBER;
  packValue(BsonBinary buffer){
     buffer.writeDouble(data);
  }
  unpackValue(BsonBinary buffer){
     data = buffer.readDouble();
  }
}