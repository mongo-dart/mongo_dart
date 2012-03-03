class BsonInt extends BsonObject{
  int data;
  BsonInt(this.data);
  get value()=>data;
  byteLength()=>4;
  int get typeByte() => BSON.BSON_DATA_INT;
  packValue(Binary buffer){
     buffer.writeInt(data);
  }
  unpackValue(Binary buffer){
     data = buffer.readInt32();
  }
}