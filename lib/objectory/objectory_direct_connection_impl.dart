#library("objectory_direct_connection");
#import("schema.dart");
#import("../mongo.dart");
#import("../bson/bson.dart");
#import("persistent_object.dart");
#import("objectory_query_builder.dart");
#source("objectory_base.dart");
Objectory get objectory() => new ObjectorySingleton._singleton();
abstract class ObjectorySingleton extends ObjectoryBaseImpl{
  static Objectory _objectory;
  ObjectorySingleton._internal();
  factory ObjectorySingleton._singleton(){
    if (_objectory === null){
      _objectory = new ObjectoryDirectConnectionImpl._internal();
    }
    return _objectory;
  }
}
class ObjectoryDirectConnectionImpl extends ObjectorySingleton{
  ObjectoryDirectConnectionImpl._internal():super._internal();
  Db db;
  
  Future<bool> open([String database, String url]){
    if (db !== null){
      db.close();
    }    
    db = new Db(database);
    return db.open();
  }
  
  void save(RootPersistentObject persistentObject){
    db.collection(persistentObject.type).save(persistentObject.map);
    persistentObject.id = persistentObject.map["_id"];
  }
  
  void remove(RootPersistentObject persistentObject){
    if (persistentObject.id === null){
      return;
    }
    db.collection(persistentObject.type).remove({"_id":persistentObject.id});
  }
  
  Future<List<RootPersistentObject>> find(ObjectoryQueryBuilder selector){    
    Completer completer = new Completer();
    var result = new List<RootPersistentObject>();
    db.collection(selector.className)
      .find(selector.map)
      .each((map){
        RootPersistentObject obj = objectory.map2Object(selector.className,map);
        result.add(obj);
      }).then((_) => completer.complete(result));
    return completer.future;  
  }
  
  Future<RootPersistentObject> findOne(ObjectoryQueryBuilder selector){
    Completer completer = new Completer();
    var obj;
    if (selector.map.containsKey("_id")) {
      obj = findInCache(selector.map["_id"]);
    }
    if (obj !== null) {
      completer.complete(obj);
    }  
    else {
      db.collection(selector.className)
        .findOne(selector.map)
        .then((map){
          if (map === null) {
           completer.complete(null); 
          }
          else {
            obj = findInCache(map["_id"]);          
            if (obj === null) {
              if (map !== null) {
                obj = objectory.map2Object(selector.className,map);
                addToCache(obj);
                }              
              }
            completer.complete(obj);
          }              
        });
      }    
    return completer.future;  
  }
  
  Future<bool> dropDb(){
    db.drop();
  }
  
  void close(){
    db.close();
  }
  
}
