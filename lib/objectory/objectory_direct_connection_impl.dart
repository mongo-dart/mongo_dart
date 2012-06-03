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
    persistentObject.id = persistentObject["_id"];
  }
  void remove(RootPersistentObject persistentObject){
    if (persistentObject.id === null){
      return;
    }
    db.collection(persistentObject.type).remove({"_id":persistentObject.id});
  }
  Future<List<IPersistent>> find(String className,[Map selector]){
    Completer completer = new Completer();
    List<IPersistent> result = new List<IPersistent>();
    db.collection(className)
      .find(selector)
      .each((map){
        RootPersistentObject obj = objectory.map2Object(className,map);
        result.add(obj);
      }).then((_) => completer.complete(result));
    return completer.future;  
  }
  Future<IPersistent> findOne(String className,[Map selector]){
    Completer completer = new Completer();    
    db.collection(className)
      .findOne(selector)
      .then((map){
        IPersistent obj;
        if (map !== null) {
          obj = objectory.map2Object(className,map);
        }  
        completer.complete(obj);
      });
    return completer.future;  
  }
  
  Future<bool> dropDb(){
    db.drop();
  }
  void close(){
    db.close();
  }
}
