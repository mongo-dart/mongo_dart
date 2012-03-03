class BsonString extends BsonObject{
  String data;
  BsonString(this.data);
  get value()=>data;
  byteLength()=>data.length+1+4;
  int get typeByte() => BSON.BSON_DATA_STRING;  
  packValue(Binary buffer){
     buffer.writeInt(data.length+1);
     buffer.bytes.setRange(buffer.offset,data.length,data.charCodes());
     buffer.offset += data.length;
     buffer.writeByte(0);
  }
}

class BsonCString extends BsonObject{
  String data;
  BsonCString(this.data);
  get value()=>data;
  byteLength()=>data.length+1;
  packValue(Binary buffer){
     buffer.bytes.setRange(buffer.offset,data.length,data.charCodes());
     buffer.offset += data.length;
     buffer.writeByte(0);    
  }
}