part of bson;
class BsonArray extends BsonObject{
  List data;
  int _dataSize;
  int dataSize(){
    if (_dataSize == null){
      _dataSize = 0;
      for(var i = 0; i < data.length; i++) {
        _dataSize += elementSize(i.toString(), data[i]);
      }
    }
    return _dataSize;
  }

  BsonArray(this.data);
  get value=>data;
  byteLength()=>dataSize()+1+4;
  int get typeByte => BSON.BSON_DATA_ARRAY;
  packValue(BsonBinary buffer){
    buffer.writeInt(byteLength());
      for(var i = 0; i < data.length; i++) {
         bsonObjectFrom(data[i]).packElement(i.toString() ,buffer);
      }
     buffer.writeByte(0);
  }

  unpackValue(BsonBinary buffer){
    data = [];
    buffer.offset += 4;
    int typeByte = buffer.readByte();
    while (typeByte != 0){
      BsonObject bsonObject = bsonObjectFromTypeByte(typeByte);
      var element = bsonObject.unpackElement(buffer);
      data.add(element.value);
      typeByte = buffer.readByte();
    }
  }

}
