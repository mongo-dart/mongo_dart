part of bson;
class BsonMap extends BsonObject{
  Map data;
  Map utfKeys;
  int _dataSize;
  int dataSize(){
    if (_dataSize === null){
      _dataSize = 0;
      data.forEach((String key, var value)
        {
           _dataSize += elementSize(key, value);
        });
    }    
    return _dataSize;
  }
  BsonMap(this.data);
  get value=>data;
  byteLength()=>dataSize()+1+4;
  int get typeByte => BSON.BSON_DATA_OBJECT;  
  packValue(BsonBinary buffer){
    buffer.writeInt(byteLength());
    data.forEach((var key, var value)
      {
         bsonObjectFrom(value).packElement(key ,buffer);
      });     
     buffer.writeByte(0);
  }
  unpackValue(BsonBinary buffer){
    data = {};    
    buffer.offset += 4;    
    int typeByte = buffer.readByte();
    while (typeByte != 0){
      BsonObject bsonObject = bsonObjectFromTypeByte(typeByte);
      var element = bsonObject.unpackElement(buffer);
      data[element.name] = element.value;    
      typeByte = buffer.readByte();
    }    
  }
}
