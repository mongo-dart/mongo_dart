interface Objectory{  
  void registerClass(ClassSchema schema);
  PersistentObject newInstance(String className);
  PersistentObject map2Object(String className, Map map);
  void addToCache(PersistentObject obj);
  PersistentObject findInCache(ObjectId id);
  Future<PersistentObject> findOne(String className,[Map selector]);
  Future<List<PersistentObject>> find(String className,[Map selector]);
  void save(PersistentObject persistentObject);
  void remove(PersistentObject persistentObject);
  Future<bool> open([String database, String url]);
  Future<bool> dropDb();
  ClassSchema getSchema(String className);
  void close();
}
abstract class ObjectoryBaseImpl implements Objectory{
  Map<String,PersistentObject> cache;
  Map<String,ClassSchema> schemata;
  ObjectoryBaseImpl(){
    schemata = new  Map<String,ClassSchema>();
    cache = new Map<String,PersistentObject>();
  }
  
  ClassSchema getSchema(String className){
    return schemata[className];
  }
  
  void addToCache(RootPersistentObject obj) {
    cache[obj.id.toHexString()] = obj;
  }
  
  RootPersistentObject findInCache(ObjectId id) {
    return cache[id.toHexString()];
  }
  
  BasePersistentObject newInstance(String className){
    if (schemata.containsKey(className)){
      return schemata[className].factoryMethod();
    }
    throw "Class $className have not been registered in Objectory";
  }
  
  BasePersistentObject map2Object(String className, Map map){
    if (map.containsKey("_id")) {
      var id = map["_id"];
      if (id !== null) {
        var res = cache[id.toHexString()];
        if (res !== null) {
          print("Object from cache:  $res");
          return res;
        }
      }        
    }    
    var result = newInstance(className);
    result.map = map;
    if (result is RootPersistentObject){
      result.id = map["_id"];    
    }
    var propertyValue;
    for (var propertySchema in schemata[className].properties.getValues()) {
      bool b = false;
      if (propertySchema.collection) {        
        propertyValue = new PersistentList<PersistentObject>(map[propertySchema.name]);
        result.setProperty(propertySchema.name,propertyValue);
      }
      else {
        if (propertySchema.internalObject) {
          propertyValue = map2Object(propertySchema.type,map[propertySchema.name]);
          propertyValue.parent = result;
          propertyValue.pathToMe = propertySchema.name;
          result.setProperty(propertySchema.name,propertyValue);          
        }
      }            
      result.clearDirtyStatus();      
    }    
    if (result is RootPersistentObject) {
      if (result.id !== null) {
        objectory.addToCache(result);
      }          
    }        
    return result;
  }
  List<PersistentObject> list2listOfObjects(){}
  void clearSchemata(){
    schemata.clear();
  }
  void registerClass(ClassSchema schema){
    schemata[schema.className] = schema;
  }
}