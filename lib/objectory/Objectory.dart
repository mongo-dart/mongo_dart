interface Objectory{  
  void registerClass(ClassSchema schema);
  IPersistent newInstance(String className);
  IPersistent map2Object(String className, Map map);  
  Future<IPersistent> findOne(String className,[Map selector]);
  Future<List<IPersistent>> find(String className,[Map selector]);
  void save(IPersistent persistentObject);
  void remove(IPersistent persistentObject);
  Future<bool> open([String database, String url]);
  Future<bool> dropDb();
  ClassSchema getSchema(String className);
  void close();
}
abstract class ObjectoryBaseImpl implements Objectory{
  Map<String,ClassSchema> schemata;
  ObjectoryBaseImpl(){
    schemata = new  Map<String,ClassSchema>();
  }
  ClassSchema getSchema(String className){
    return schemata[className];
  }
  IPersistent newInstance(String className){
    if (schemata.containsKey(className)){
      return schemata[className].factoryMethod();
    }
    throw "Class $className have not been registered in Objectory";
  }
  IPersistent map2Object(String className, Map map){
    var result = newInstance(className);
    result.map = map;
    if (result.isRoot()){
      result.id = map["_id"];    
    }
    var propertyValue;
    for (var propertySchema in schemata[className].properties.getValues()) {
      bool b = false;
      if (propertySchema.collection) {        
        propertyValue = new PersistentList<IPersistent>(map[propertySchema.name]);
        result.setProperty(propertySchema.name,propertyValue);
      }
      else {
        if (propertySchema.internalObject) {
          propertyValue = map2Object(propertySchema.type,map[propertySchema.name]);
          propertyValue.parent = result;
          propertyValue.pathToMe = propertySchema.name;
          result.setProperty(propertySchema.name,propertyValue);          
        }
        if (propertySchema.externalRef) {
          ObjectId linkId = map[propertySchema.name];
          if (linkId !== null){
            propertyValue = newInstance(propertySchema.type);
            propertyValue.id = linkId;
            result.setProperty(propertySchema.name,propertyValue);            
          } 
        }        
      }            
      result.clearDirtyStatus();      
    }
    return result;
  }
  List<IPersistent> list2listOfObjects(){}
  void clearSchemata(){
    schemata.clear();
  }
  void registerClass(ClassSchema schema){
    schemata[schema.className] = schema;
  }
}