// noSuchMethod() borrowed from Chris Buckett (chrisbuckett@gmail.com)
// http://github.com/chrisbu/dartwatch-JsonObject
interface PersistentObject{
  noSuchMethod(String function_name, List args);
  void setProperty(String property, value);
  void init();
  String get type();
  void clearDirtyStatus();
  Future fetchLink(String property);
  Future fetchLinks();
}
abstract class PersistentObjectBase extends MapProxy implements PersistentObject{  
  bool setupMode;
  Set<String> dirtyFields;
  PersistentObjectBase(){        
    if (isRoot()){
      map["_id"] = null;
    }                
    init();
    dirtyFields = new Set<String>();
  }  
  void setDirty(String fieldName){
    if (dirtyFields === null){
      return;
    }
    dirtyFields.add(fieldName);
  }  
void clearDirtyStatus(){
  dirtyFields.clear();
}
  onValueChanging(String fieldName, newValue){
    setDirty(fieldName);
  }
  isDirty(){
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
      if (schema.properties.contains(property)) {
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
      if (schema.properties.contains(property)) {
        if (schema.links !== null){
          if (schema.links.containsKey(property)){
            if (value.id === null){
              throw "Error setting link property $property. Link object must have not null id";
            }            
            value = value.id;
          }
        }
        onValueChanging(property, value);
        this[property] = value;
        if (value is InnerPersistentObject){
          value.pathToMe = property;
          value.parent = this;
        } 
        return this[property];
      }
      else {       
        super.noSuchMethod(function_name, args);
      }        
    }    
    //if we get here, then we've not found it - throw.
    super.noSuchMethod(function_name, args);
  }
  void setProperty(String property, value){
    noSuchMethod('set:$property',[value]);
  }
  Dynamic get(String property){
    return noSuchMethod('get:$property');
  }  
  String toString()=>"$type($map)";
  void init(){}  
  abstract String get type();
  abstract bool isRoot();
  Future<PersistentObject> fetchLink(String property, [Map links]){
    var completer = new Completer<PersistentObject>();
    if (links === null){
      links = objectory.getSchema(type).links;
    }          
    if (links === null || !links.containsKey(property)){
      throw "Link $property is not registered on class $type";
    }
    var value = map[property];    
    if (value !== null){
      objectory.findOne(links[property],{"_id":value}).then((res){
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
    var links = objectory.getSchema(type).links;
    if (links === null ){
      throw "Links are not registered on class $type";
    }
    var futures = new List<Future>();
    for (var link in links.getKeys()){
      futures.add(fetchLink(link,links));
    }
    return Futures.wait(futures);
  }

}
abstract class RootPersistentObject extends PersistentObjectBase{
   ObjectId id;
   bool isRoot()=>true;
}
abstract class InnerPersistentObject extends PersistentObjectBase{
  PersistentObject parent;
  String pathToMe;
  bool isRoot()=>false;
}