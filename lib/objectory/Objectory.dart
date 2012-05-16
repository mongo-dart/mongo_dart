typedef PersistentObject FactoryMethod();
interface Objectory{  
  void registerClass(String className, FactoryMethod fm);
  Future<PersistentObject> findOne(String className,[Map query]);
  Future<List<PersistentObject>> find(String className,[Map query]);
  void save(PersistentObject persistentObject);
  void remove(PersistentObject persistentObject);
  Future<bool> connect(String database, [String url]);
  Future<bool> dropDb();
}
class ObjectoryBaseImpl implements Objectory{
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
    return result;
  }
  void registerClass(String className, FactoryMethod fm){
    factories[className] = fm;
  }
}