typedef IPersistent FactoryMethod();
class ClassSchema{
  static final SimpleProperty = 0;
  static final InternalObject = 1;
  static final ExternalObject = 2;
  String className;
  FactoryMethod factoryMethod;
  Set<String> properties;
  Map<String,String> components;
  Map<String,String> links;
  ClassSchema(this.className,this.factoryMethod,List<String> propertyList,    
    [this.components,this.links]){
    properties = new Set<String>.from(propertyList);
    if (components !== null){
      properties.addAll(components.getKeys());
    }
    if (links !== null){
      properties.addAll(links.getKeys());
    }
  }    
  void property(String propertyName, String propertyClass){
    
  }
}
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
    ClassSchema classSchema = schemata[className];
    if (classSchema.components !== null){      
      classSchema.components.forEach((property,componentClass){
        IPersistent component = map2Object(componentClass,map[property]);
        result.setProperty(property,component);
        result.clearDirtyStatus();
      });
    }
    if (classSchema.links !== null){      
      classSchema.links.forEach((property,linkClass){
      //  print(property);
        ObjectId linkId = map[property];
        if (linkId !== null){
          RootPersistentObject link = newInstance(linkClass);
          link.id = linkId;
          result.setProperty(property,link);
          result.clearDirtyStatus();
        }          
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