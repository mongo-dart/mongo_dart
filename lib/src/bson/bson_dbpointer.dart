part of bson;
class BsonDbPointer extends BsonObject{
  String collection;
  ObjectId id;
  BsonString bsonCollection;
  
  
  BsonDbPointer(this.collection, this.id)
  {      
    bsonCollection = new BsonString(collection);    
  }  
  get value=>this;
  int get typeByte => BSON.BSON_DATA_DBPOINTER;  
  byteLength()=>bsonCollection.byteLength()+id.byteLength();
  unpackValue(Binary buffer){    
    bsonCollection = new BsonString(null);
    bsonCollection.unpackValue(buffer);
    collection = bsonCollection.data;
    id = new ObjectId();
    id.unpackValue(buffer);
  }   
  toString()=>'BsonDbPointer(collection: $collection, id: $id)';
  packValue(Binary buffer){     
     bsonCollection.packValue(buffer);
     id.packValue(buffer);
  }
  hashCode() => '${collection}.${id.toHexString()}'.hashCode();
  bool operator ==(other) => collection == other.collection && id.toHexString() == other.id.toHexString(); 
  
}