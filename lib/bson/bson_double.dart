class BsonDouble extends BsonObject{
  double data;
  BsonDouble(this.data);
  get value()=>data;
  byteLength()=>8;
  int get typeByte() => BSON.BSON_DATA_NUMBER;
  packValue(Binary buffer){
     buffer.writeDouble(data);
  }
  unpackValue(Binary buffer){
     data = buffer.readDouble();
  }
}