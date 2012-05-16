// noSuchMethod() borrowed from Chris Buckett (chrisbuckett@gmail.com)
// http://github.com/chrisbu/dartwatch-JsonObject
class PersistentObject extends _MapProxy{  
  PersistentObject.fromMap(Map map): super.fromMap(map);
  Set<String> dirtyFields;
  ObjectId id;
  PersistentObject(){        
    map = null;
    dirtyFields = new Set<String>();      
    init();
//    abstract bool isRoot();
  }
  PersistentObject.makeTransient(){

  }
  setDirty(String fieldName){
    dirtyFields.add(fieldName);
  }
  onValueChanging(String fieldName, newValue){
    setDirty(fieldName);
  }
  isDirty(){
    return !dirtyFields.isEmpty();
  }

  noSuchMethod(String function_name, List args) {
    if (map === null){
       map =  new LinkedHashMap();
    }
    if (args.length == 0 && function_name.startsWith("get:")) {
      //synthetic getter
      var property = function_name.replaceFirst("get:", "");
      if (this.containsKey(property)) {
        return this[property];
      }
      else{
        return null;
      }
    }
    else if (args.length == 1 && function_name.startsWith("set:")) {
      //synthetic setter
      var property = function_name.replaceFirst("set:", "");
      onValueChanging(property, args[0]);
      this[property] = args[0];
      return this[property];
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
  void init(){
  }  
  abstract String get type();
  static Future<List<PersistentObject>>find(Map query){
  }
  static Future<PersistentObject>findOne(Map query){
  }  
}