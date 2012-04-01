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
  unpackValue(Binary buffer){
     int size = buffer.readInt32()-1; 
     List<int> utf8Bytes = buffer.bytes.getRange(buffer.offset,size);
     data = decodeUtf8(utf8Bytes);
     buffer.offset += size+1;
  }

}
class BsonCode extends BsonString{
  get value()=>this;
  int get typeByte() => BSON.BSON_DATA_CODE;
  BsonCode(String data):super(data);
  String toString()=>"BsonCode('$data')";  
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