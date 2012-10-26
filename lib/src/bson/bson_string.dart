part of bson;
class BsonString extends BsonObject{
  String data;
  List<int> _utfData;  
  List<int> get utfData{
    if (_utfData === null){
      _utfData = encodeUtf8(data);
    }
    return _utfData;
  }  
  BsonString(this.data);
  get value=>data;
  byteLength()=>utfData.length+1+4;
  int get typeByte => BSON.BSON_DATA_STRING;  
  packValue(BsonBinary buffer){
     buffer.writeInt(utfData.length+1);
     buffer.byteList.setRange(buffer.offset,utfData.length,utfData);
     buffer.offset += utfData.length;
     buffer.writeByte(0);
  }
  unpackValue(BsonBinary buffer){
     int size = buffer.readInt32()-1;     
     data = decodeUtf8(buffer.byteList,buffer.offset,size);
     buffer.offset += size+1;
  }
}
class BsonCode extends BsonString{
  get value=>this;
  int get typeByte => BSON.BSON_DATA_CODE;
  BsonCode(String dataValue):super(dataValue);
  String toString()=>"BsonCode('$data')";  
}
class BsonCString extends BsonString{
  bool useKeyCash;
  int get typeByte{
   throw "Function typeByte of BsonCString must not be called";
  }   
  BsonCString(String data, [this.useKeyCash = true]): super(data);
  List<int> get utfData{
    if (useKeyCash){
      return Statics.getKeyUtf8(data);
    }
    else {
      return super.utfData;
    }    
  }  

  byteLength()=>utfData.length+1;
  packValue(BsonBinary buffer){
     buffer.byteList.setRange(buffer.offset,utfData.length,utfData);
     buffer.offset += utfData.length;
     buffer.writeByte(0);
  }  
}