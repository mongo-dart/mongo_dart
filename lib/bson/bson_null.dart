class BsonNull extends BsonObject{  
  BsonNull();
  get value()=>null;
  byteLength()=>0;
  int get typeByte() => BSON.BSON_DATA_NULL;
  packValue(Binary buffer){     
  }
  unpackValue(Binary buffer){  
  }
}