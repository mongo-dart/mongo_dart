part of bson;
class DbRef extends BsonObject{
  String collection;
  ObjectId id;
  BsonString bsonCollection;
  DbRef(this.collection, this.id)
  {      
    bsonCollection = new BsonString(collection);    
  }  
  get value=>this;
  int get typeByte => BSON.BSON_DATA_DBPOINTER;  
  byteLength()=>bsonCollection.byteLength()+id.byteLength();
  unpackValue(BsonBinary buffer){    
    bsonCollection = new BsonString(null);
    bsonCollection.unpackValue(buffer);
    collection = bsonCollection.data;
    id = new ObjectId();
    id.unpackValue(buffer);
  }   
  toString()=>'BsonDbPointer(collection: $collection, id: $id)';
  packValue(BsonBinary buffer){     
     bsonCollection.packValue(buffer);
     id.packValue(buffer);
  }
  hashCode() => '${collection}.${id.toHexString()}'.hashCode();
  bool operator ==(other) => other is DbRef && collection == other.collection && id.toHexString() == other.id.toHexString();
   
}