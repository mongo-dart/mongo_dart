// noSuchMethod() borrowed from Chris Buckett (chrisbuckett@gmail.com)
// http://github.com/chrisbu/dartwatch-JsonObject
interface IPersistent{  
  noSuchMethod(String function_name, List args);
  void setProperty(String property, value);
  void init();
  String get type();
  void clearDirtyStatus();
  bool isDirty();
  Future fetchLink(String property);
  Future fetchLinks();
  bool isRoot();
  Map map;
}
abstract class PersistentObjectBase extends MapProxy implements IPersistent{
  Map<String,RootPersistentObject> objectCache;  
  bool setupMode;
  Set<String> dirtyFields;
  PersistentObjectBase() {
    objectCache = new Map<String,RootPersistentObject>();
    if (isRoot()){
      map["_id"] = null;
    }                
    init();
    dirtyFields = new Set<String>();
  }  
  void setDirty(String fieldName) {
    if (dirtyFields === null){
      return;
    }
    dirtyFields.add(fieldName);
  }  
void clearDirtyStatus() {
  dirtyFields.clear();
}
  onValueChanging(String fieldName, newValue) {
    setDirty(fieldName);
  }
  isDirty() {
    return !dirtyFields.isEmpty();
  }
  noSuchMethod(String function_name, List args) {
    ClassSchema schema = objectory.getSchema(type);
    if (schema === null){
      throw "Class $type have not been registered in Objectory";
    }
    if (args.length == 0 && function_name.startsWith("get:")) {
      //synthetic getter
      var property = function_name.replaceFirst("get:", "");      
      if (schema.properties.containsKey(property)) {
        return this[property];
      }
      else{
        super.noSuchMethod(function_name, args);
      }
    }
    else if (args.length == 1 && function_name.startsWith("set:")) {
      //synthetic setter
      var value = args[0];
      var property = function_name.replaceFirst("set:", "");
      PropertySchema propertySchema = schema.properties[property];
      if (propertySchema !== null) {
        if (propertySchema.externalRef && !propertySchema.collection){
          if (value !== null) {            
            if (value.id === null){        
              throw "Error setting link property $property. Link object must have not null id";
            }            
            value = value.id;
          }          
        }
        onValueChanging(property, value);
        this[property] = value;
        if (value is InnerPersistentObject || value is PersistentList){
          value.pathToMe = property;
          value.parent = this;
        } 
        return this[property];
      }
      else {       
        print("Not registered property $property on for class $type");
        print(schema.properties);
        super.noSuchMethod(function_name, args);
      }        
    }    
    //if we get here, then we've not found it - throw.
    super.noSuchMethod(function_name, args);
  }
  void setProperty(String property, value){
    noSuchMethod('set:$property',[value]);
  }
  Dynamic getProperty(String property){
    return noSuchMethod('get:$property',[]);
  }  
  String toString()=>"$type($map)";
  void init(){}  
  abstract String get type();  
  Future<IPersistent> fetchLink(String property, [PropertySchema propertySchema]){
    
    var completer = new Completer<IPersistent>();
    if (propertySchema === null){
      propertySchema = objectory.getSchema(type).properties[property];
    }          
    if (propertySchema === null){
      throw "Property $property is not registered on class $type";
    }
    if (!propertySchema.externalRef){
      print(propertySchema);
      throw "Property $property is not of external ref type on class $type";
    }    
    var value = map[property];    
    if (value !== null){
      objectory.findOne(propertySchema.type,{"_id":value}).then((res){
        map[property] = res;
        completer.complete(res);
      });
    }
    else
    {
      completer.complete(null);
    }      
    return completer.future;
  }
  Future fetchLinks(){
    var futures = new List();
    for (var propertySchema in objectory.getSchema(type).properties.getValues()) {
      if (propertySchema.externalRef) {
        futures.add(fetchLink(propertySchema.name, propertySchema));
      }          
    }
    return Futures.wait(futures);
  }

}
abstract class RootPersistentObject extends PersistentObjectBase{
   ObjectId id;
   bool isRoot()=>true;
}
abstract class InnerPersistentObject extends PersistentObjectBase{
  IPersistent parent;
  String pathToMe;
  bool isRoot()=>false;
  void setDirty(String fieldName){
    super.setDirty(fieldName);
    if (parent !== null) {
      parent.setDirty(pathToMe);
    }
  }  
}