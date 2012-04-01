class Binary extends BsonObject{
  static final BUFFER_SIZE = 256;
  static final SUBTYPE_DEFAULT = 0;
  static final SUBTYPE_FUNCTION = 1;
  static final SUBTYPE_BYTE_ARRAY = 2;
  static final SUBTYPE_UUID = 3;
  static final SUBTYPE_MD5 = 4;
  static final SUBTYPE_USER_DEFINED = 128;
  //static final minBits = [1,2,3,4];
  ByteArray bytes;
  int offset;
  int subType;
  Binary(int length): bytes = new ByteArray(length),offset=0, subType=0;
  Binary.from(List from): bytes = new ByteArray(from.length),offset=0, subType=0{
    bytes.setRange(0, from.length, from);
  }  
  int get typeByte() => BSON.BSON_DATA_BINARY;  
  String toHexString(){
    StringBuffer stringBuffer = new StringBuffer();
    for (final byte in bytes)
    {      
       if (byte < 16){
        stringBuffer.add("0");
       }       
       stringBuffer.add(byte.toRadixString(16));
    }
    return stringBuffer.toString().toLowerCase();
  }  
  setIntExtended(int value, int numOfBytes){
    ByteArray bytesTmp = new ByteArray(8);
    if (numOfBytes == 3){
      bytesTmp.setInt32(0,value);
    }
    else if (numOfBytes > 4 && numOfBytes < 8){
      bytesTmp.setInt64(0,value);
    }
    else {
        throw new Exception("Unsupported num of bits: ${numOfBytes*8}");
    }
    bytes.setRange(offset,numOfBytes,bytesTmp);
  }
  reverse(int numOfBytes){
    swap(int x, int y){
      int t = bytes[x+offset];
      bytes[x+offset] = bytes[y+offset];
      bytes[y+offset] = t;
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
        bytes.setInt32(position,value);        
        if (value == -1){   
        // That is temporary workaround on ByteArray broken functionality on negative ints
        //TODO Remove this, when ByteArray will be repaired         
          bytes.setRange(position, 4, [255,255,255,255]);          
        }           
        break;
      case 16: 
        bytes.setInt16(position,value);
        break;
      case 8: 
        bytes.setInt8(position,value);        
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
    bytes.setFloat64(offset, value);
    offset+=8;
  } 
  int writeInt64(int value){    
    bytes.setInt64(offset, value);
    offset+=8;
  } 
  int readByte(){    
    return bytes[offset++];
  }
  int readInt32(){    
    offset+=4;
    return bytes.getInt32(offset-4);    
  }  
  int readInt64(){    
    offset+=8;
    return bytes.getInt64(offset-8);
  }    
  num readDouble(){    
    offset+=8;
    return bytes.getFloat64(offset-8);
  }    

  String readCString(){ 
    List<int> stringBytes = [];
    while (bytes[offset++]!= 0){
       stringBytes.add(bytes[offset-1]);
    }
    return new String.fromCharCodes(stringBytes);
  }
  writeCString(List<int> charCodes){
    bytes.setRange(offset,charCodes.length,charCodes);
    offset += charCodes.length;
    writeByte(0);    
 }

  int byteLength() => bytes.length+4+1;
  bool atEnd() => offset == bytes.length;
  rewind(){
    offset = 0;
  }
  packValue(Binary buffer){
    buffer.writeInt(bytes.length);
    buffer.writeByte(subType);
    buffer.bytes.setRange(buffer.offset,bytes.length,bytes);
    buffer.offset += bytes.length;        
  }  
  unpackValue(Binary buffer){
    int size = buffer.readInt32();
    subType = buffer.readByte();
    bytes = new ByteArray(size);
    bytes.setRange(0,size,buffer.bytes,buffer.offset);
    buffer.offset += size;  
  }
  get value()=>this;
  String toString()=>"Binary(${toHexString()})";
}
