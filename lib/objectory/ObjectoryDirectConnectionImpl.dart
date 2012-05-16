Objectory get objectory() => new ObjectorySingleton._singleton();
class ObjectorySingleton extends ObjectoryBaseImpl{
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
  Future<bool> open(String database, [String url]){
    db = new Db(database);
    return db.open();
  }
  void save(PersistentObject persistentObject){
    db.collection(persistentObject.type).save(persistentObject);
  }
  void remove(PersistentObject persistentObject){
    db.save(persistentObject);
  }
  Future<List<PersistentObject>> find(String className,[Map query]){
    Completer completer = new Completer();
    List<PersistentObject> result = new List<PersistentObject>();
    db.collection(className)
      .find(query)
      .each((map){
        PersistentObject obj = objectory.newInstance(className);
        obj.map = map;
        obj.id = map["_id"];
        result.add(obj);
      }).then((_) => completer.complete(result));
    return completer.future;  
  }
}
