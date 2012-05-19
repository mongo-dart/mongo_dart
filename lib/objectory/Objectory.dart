typedef PersistentObject FactoryMethod();
interface Objectory{  
  void registerClass(String className, FactoryMethod fm);
  PersistentObject newInstance(String className);
  Future<PersistentObject> findOne(String className,[Map selector]);
  Future<List<PersistentObject>> find(String className,[Map selector]);
  void save(PersistentObject persistentObject);
  void remove(PersistentObject persistentObject);
  Future<bool> open(String database, [String url]);
  Future<bool> dropDb();
}
abstract class ObjectoryBaseImpl implements Objectory{
  Map<String,FactoryMethod> factories;
  ObjectoryBaseImpl(){
    factories = new  Map<String,FactoryMethod>();
  }
  PersistentObject newInstance(String className){
    if (factories.containsKey(className)){
      return factories[className]();
    }
    throw "Class $className have not been registered in Objectory";
  }
  PersistentObject map2Object(String className, Map map){
    PersistentObject result = newInstance(className);
    result.map = map;
    if (result.isRoot()){
      result.id = map["_id"];    
    }      
    for (var key in map.getKeys()){
      var value = map[key];
      if (value is Map){
        if (value.containsKey("_pt")){
          PersistentObject subComponent = map2Object(value["_pt"],value);
          result.setProperty(key,subComponent);  
          result.clearDirtyStatus();
        }
      }
    }
    return result;
  }
  void clearFactories(){
    factories.clear();
  }
  void registerClass(String className, FactoryMethod fm){
    factories[className] = fm;
  }
}