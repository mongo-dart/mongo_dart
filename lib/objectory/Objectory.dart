typedef PersistentObject FactoryMethod();
class ClassSchema{
  String className;
  FactoryMethod factoryMethod;
  Set<String> properties;
  Map<String,String> links;  
  ClassSchema(this.className,this.factoryMethod,List<String> propertyList,
    [this.links]){
    properties = new Set<String>.from(propertyList);
  }
    
}
interface Objectory{  
  void registerClass(ClassSchema schema);
  PersistentObject newInstance(String className);
  Future<PersistentObject> findOne(String className,[Map selector]);
  Future<List<PersistentObject>> find(String className,[Map selector]);
  void save(PersistentObject persistentObject);
  void remove(PersistentObject persistentObject);
  Future<bool> open(String database, [String url]);
  Future<bool> dropDb();
  ClassSchema getSchema(String className);
}
abstract class ObjectoryBaseImpl implements Objectory{
  Map<String,ClassSchema> schemata;
  ObjectoryBaseImpl(){
    schemata = new  Map<String,ClassSchema>();
  }
  ClassSchema getSchema(String className){
    return schemata[className];
  }
  PersistentObject newInstance(String className){
    if (schemata.containsKey(className)){
      return schemata[className].factoryMethod();
    }
    throw "Class $className have not been registered in Objectory";
  }
  PersistentObject map2Object(String className, Map map){
    PersistentObject result = newInstance(className);
    result.map = map;
    if (result.isRoot()){
      result.id = map["_id"];    
    }      
    ClassSchema classSchema = schemata[className];
    if (classSchema.links !== null){      
      classSchema.links.forEach((property,linkClass){
        PersistentObject linkObject = map2Object(linkClass,map[property]);
        result.setProperty(property,linkObject);  
        result.clearDirtyStatus();
      });
    }
    return result;
  }
  void clearSchemata(){
    schemata.clear();
  }
  void registerClass(ClassSchema schema){
    schemata[schema.className] = schema;
  }
}