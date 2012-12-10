part of bson;

class BsonBoolean extends BsonObject{
  bool data;
  BsonBoolean(this.data);
  get value=>data;
  byteLength()=>1;
  int get typeByte => BSON.BSON_DATA_BOOLEAN;
  packValue(Binary buffer){
     buffer.writeByte(data?1:0);
  }
  unpackValue(Binary buffer){
     var b = buffer.readByte();
     if (b == 1){
       data = true;
     }
     else{
       data = false;
     }
  }
}