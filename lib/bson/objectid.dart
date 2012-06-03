class ObjectId extends BsonObject{  
  Binary id;
  factory ObjectId(){
    Timestamp ts = new Timestamp(null,0);    
    return new ObjectId.fromSeconds(ts.seconds);
  }
  ObjectId.fromSeconds(int seconds): id=new Binary(12){
    id.writeInt(seconds,4,forceBigEndian:true);
    /* Todo - restore whan Math.random would work
    id.writeInt(Statics.MachineId,3);
    id.writeInt(Statics.Pid,2);    
    */
    id.writeInt((seconds & 0xFFFFFF).floor().toInt(),3);
    id.writeInt((seconds & 0xFFFF).floor().toInt(),2);
    id.writeInt(Statics.nextIncrement,3,forceBigEndian:true);
  }
  int hashCode() => id.toHexString().hashCode();
  String toString()=>"ObjectId(${id.toHexString()})";
  int get typeByte() => BSON.BSON_DATA_OID;
  get value() => this;
  int byteLength() => 12;
  unpackValue(Binary buffer){
     id.byteList.setRange(0,12,buffer.byteList,buffer.offset);
     buffer.offset += 12;
  }
  packValue(Binary buffer){
    buffer.byteList.setRange(buffer.offset,12,id.byteList);
    buffer.offset += 12;
  } 
}