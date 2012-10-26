part of bson;
class _ElementPair{
  String name;
  var value;
  _ElementPair([this.name,this.value]);
}
class BsonObject {  
  int get typeByte{ throw const Exception("must be implemented");}
  int byteLength() => 0;
  packElement(String name, var buffer){
    buffer.writeByte(typeByte);
    if (name !== null){
      new BsonCString(name).packValue(buffer);
    }
    packValue(buffer);
  } 
  packValue(var buffer){ throw const Exception("must be implemented");}
  _ElementPair unpackElement(buffer){
    _ElementPair result = new _ElementPair();
    result.name = buffer.readCString();    
    unpackValue(buffer);
    result.value = value;
    return result;
  }
  unpackValue(var buffer){ throw const Exception("must be implemented");}
  get value=>null;
}
int elementSize(String name, value) {
  int size = 1;
  if (name !== null){
    size += Statics.getKeyUtf8(name).length + 1;
  } 
  size += bsonObjectFrom(value).byteLength();
  return size;
}
BsonObject bsonObjectFrom(var value){
  if (value is BsonObject){
    return value;
  }
  if (value is int){
    return new BsonInt(value);
  }    
  if (value is num){
    return new BsonDouble(value);
  } 

  if (value is String){
    return new BsonString(value);
  }        
  if (value is Map){
    return new BsonMap(value);
  }        
  if (value is List){
    return new BsonArray(value);
  }        
  if (value === null){
    return new BsonNull();
  }
  if (value is Date){
    return new BsonDate(value);
  }  
  if (value === true || value === false){
    return new BsonBoolean(value);
  }
  if (value is BsonRegexp){
    return value;
  }  
  throw new Exception("Not implemented for $value");           
}  

BsonObject bsonObjectFromTypeByte(int typeByte){
  switch(typeByte){
    case BSON.BSON_DATA_INT:
      return new BsonInt(null);
    case BSON.BSON_DATA_LONG:
      return new BsonLong(null);
    case BSON.BSON_DATA_NUMBER:
      return new BsonDouble(null);
    case BSON.BSON_DATA_STRING:
      return new BsonString(null);
    case BSON.BSON_DATA_ARRAY:
      return new BsonArray([]);
    case BSON.BSON_DATA_OBJECT:
      return new BsonMap({});
    case BSON.BSON_DATA_OID:
      return new ObjectId();
    case BSON.BSON_DATA_NULL:
      return new BsonNull();
    case BSON.BSON_DATA_DBPOINTER:
      return new DbRef(null,null);      
    case BSON.BSON_DATA_BOOLEAN:
      return new BsonBoolean(false);
    case BSON.BSON_DATA_BINARY:
      return new BsonBinary(0);
    case BSON.BSON_DATA_DATE:
      return new BsonDate(null);
    case BSON.BSON_DATA_CODE:
      return new BsonCode(null);
    case BSON.BSON_DATA_REGEXP:
      return new BsonRegexp(null);      
    default:
      throw new Exception("Not implemented for BSON TYPE $typeByte");           
  }  
}

