class Binary extends BsonObject{
  static final BUFFER_SIZE = 256;
  static final SUBTYPE_DEFAULT = 0;
  static final SUBTYPE_FUNCTION = 1;
  static final SUBTYPE_BYTE_ARRAY = 2;
  static final SUBTYPE_UUID = 3;
  static final SUBTYPE_MD5 = 4;
  static final SUBTYPE_USER_DEFINED = 128;
  //static final minBits = [1,2,3,4];
  ByteArray byteArray;
  Uint8List byteList;
  int offset;
  int subType;
  Binary(int length): byteList = new Uint8List(length), offset=0, subType=0{
    byteArray = byteList.asByteArray();    
  }
  Binary.from(List from): byteList = new Uint8List(from.length),offset=0, subType=0 {    
    byteList.setRange(0, from.length, from);
    byteArray = byteList.asByteArray();    
  }  
  int get typeByte() => BSON.BSON_DATA_BINARY;  
  String toHexString(){
    StringBuffer stringBuffer = new StringBuffer();
    for (final byte in byteList)
    {      
       if (byte < 16){
        stringBuffer.add("0");
       }       
       stringBuffer.add(byte.toRadixString(16));
    }
    return stringBuffer.toString().toLowerCase();
  }  
  setIntExtended(int value, int numOfBytes){
    Uint8List byteListTmp = new Uint8List(8);    
    ByteArray byteArrayTmp = byteListTmp.asByteArray();
    if (numOfBytes == 3){
      byteArrayTmp.setInt32(0,value);
    }
    else if (numOfBytes > 4 && numOfBytes < 8){
      byteArrayTmp.setInt64(0,value);
    }
    else {
        throw new Exception("Unsupported num of bits: ${numOfBytes*8}");
    }
    byteList.setRange(offset,numOfBytes,byteListTmp);
  }
  reverse(int numOfBytes){
    swap(int x, int y){
      int t = byteList[x+offset];
      byteList[x+offset] = byteList[y+offset];
      byteList[y+offset] = t;
    }
    for(int i=0;i<=(numOfBytes-1)%2;i++){
      swap(i,numOfBytes-1-i);
    }
  }
  encodeInt(int position,int value, int numOfBytes, bool forceBigEndian, bool signed) {
    int bits = numOfBytes << 3; 
    int max = Statics.MaxBits(bits);

    if (value >= max || value < -(max / 2)) {
      throw new Exception("encodeInt::overflow");      
    }
    switch(bits) {
      case 32:
        byteArray.setInt32(position,value);        
        break;
      case 16: 
        byteArray.setInt16(position,value);
        break;
      case 8: 
        byteArray.setInt8(position,value);        
        break;
      case 24:        
        setIntExtended(value,numOfBytes);
        break;      
      default:
        throw new Exception("Unsupported num of bits: $bits");
    }
    if (forceBigEndian){
      reverse(numOfBytes);
    }
  }
  writeInt(int value, [int numOfBytes=4,bool forceBigEndian=false, bool signed=false]){
    encodeInt(offset,value, numOfBytes,forceBigEndian,signed);
    offset += numOfBytes;
  }
  writeByte(int value){
    encodeInt(offset,value, 1,false,false);
    offset += 1;
  }
  int writeDouble(double value){    
    byteList.setFloat64(offset, value);
    offset+=8;
  } 
  int writeInt64(int value){    
    byteArray.setInt64(offset, value);
    offset+=8;
  } 
  int readByte(){    
    return byteList[offset++];
  }
  int readInt32(){    
    offset+=4;
    return byteArray.getInt32(offset-4);    
  }  
  int readInt64(){    
    offset+=8;
    return byteArray.getInt64(offset-8);
  }    
  num readDouble(){    
    offset+=8;
    return byteArray.getFloat64(offset-8);
  }    

  String readCString(){ 
    List<int> stringBytes = [];
    while (byteList[offset++]!= 0){
       stringBytes.add(byteList[offset-1]);
    }
    return decodeUtf8(stringBytes);
  }
  writeCString(String val){
    final utfData = encodeUtf8(val);
    byteList.setRange(offset,utfData.length,utfData);
    offset += utfData.length;
    writeByte(0);    
 }

  int byteLength() => byteList.length+4+1;
  bool atEnd() => offset == byteList.length;
  rewind(){
    offset = 0;
  }
  packValue(Binary buffer){
    buffer.writeInt(byteList.length);
    buffer.writeByte(subType);
    buffer.byteList.setRange(buffer.offset,byteList.length,byteList);
    buffer.offset += byteList.length;        
  }  
  unpackValue(Binary buffer){
    int size = buffer.readInt32();
    subType = buffer.readByte();
    byteList = new Uint8List(size);
    byteArray = byteList.asByteArray();
    byteList.setRange(0,size,buffer.byteList,buffer.offset);
    buffer.offset += size;  
  }
  get value()=>this;
  String toString()=>"Binary(${toHexString()})";
}
