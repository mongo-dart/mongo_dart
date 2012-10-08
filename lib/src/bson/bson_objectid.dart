part of bson;
class ObjectId extends BsonObject{  
  Binary id;
  
  ObjectId([bool clientMode = false]){
    int seconds = new Timestamp(null,0).seconds;    
    id = createId(seconds, clientMode);
  }
  
  ObjectId.fromSeconds(int seconds, [bool clientMode = false]){
    id = createId(seconds, clientMode);
  }
  ObjectId.fromBinary(this.id);
  
  Binary createId(int seconds, bool clientMode) {
      getOctet(int value) {
      String res = value.toRadixString(16);
      while (res.length < 8) {
        res = '0$res';
      }
      return res;
    }
    if (clientMode) {
      String s = '${getOctet(seconds)}${getOctet(Statics.MachineId+Statics.Pid)}${getOctet(Statics.nextIncrement)}';
      return new Binary.fromHexString(s);
    } else {
      return new Binary(12)
      ..writeInt(seconds,4,forceBigEndian:true)    
      ..writeInt(Statics.MachineId,3)
      ..writeInt(Statics.Pid,2)
      ..writeInt(Statics.nextIncrement,3,forceBigEndian:true);
    }    
  }  
  
  
  factory ObjectId.fromHexString(String hexString) {
    return new ObjectId.fromBinary(new Binary.fromHexString(hexString));
  }    

  
  int hashCode() => id.hexString.hashCode();
  bool operator ==(other) => other is ObjectId && toHexString() == other.toHexString();
  String toString() => "ObjectId(${id.hexString})";
  String toHexString() => id.hexString;
  int get typeByte => BSON.BSON_DATA_OID;
  get value => this;
  int byteLength() => 12;
  unpackValue(Binary buffer){
     id.byteList.setRange(0,12,buffer.byteList,buffer.offset);
     buffer.offset += 12;
  }
  packValue(Binary buffer){
    if (id.byteList == null) {
      id.makeByteList();  
    }
    buffer.byteList.setRange(buffer.offset,12,id.byteList);
    buffer.offset += 12;
  }
  
  String toJson() {    
    return '\{"\$oid":"${toHexString()}"\}';
  }
  
}