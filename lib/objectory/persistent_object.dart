#library("persistent_object");
#import("schema.dart");
#import("objectory_query_builder.dart");
#import("../bson/bson.dart");
#import("objectory_base.dart");
#source("persistent_list.dart");
interface PersistentObject{
  Future fetchLink(String property);
  Future fetchLinks();
  void save();
  void remove();
}
abstract class BasePersistentObject implements PersistentObject{
  LinkedHashMap map;  
  bool setupMode;
  Set<String> dirtyFields;
  
  BasePersistentObject() {
    map = new LinkedHashMap();
    _initMap();
    init();
    dirtyFields = new Set<String>();
  }
  
  void _initMap() {
    var schema = objectory.getSchema(type);
    schema.properties.forEach((property,propertySchema) {
      if (propertySchema.collection) {
        map[property] = [];
      } else if (propertySchema.embeddedObject){
        map[property] = {};  
      }
      else {
        if (schema.preserveFieldsOrder) {
          map[property] = null;
        }
      }
    });      
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
  
  void onValueChanging(String fieldName, newValue) {
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
    PropertySchema propertySchema;
    if (args.length == 0 && function_name.startsWith("get:")) {
      //synthetic getter
      var property = function_name.replaceFirst("get:", "");
      propertySchema = schema.properties[property];
      if (propertySchema === null) {
        super.noSuchMethod(function_name, args);
      }      
      final value = this.map[property];      
      if (propertySchema.collection) {
        return new PersistentList(value, parent: this, pathToMe: property);
      }
      if (propertySchema.embeddedObject) {
        EmbeddedPersistentObject result =  objectory.map2Object(propertySchema.type, value);
        result.parent = this;
        result.pathToMe = property;
        return result;
      }
      if (propertySchema.link)  {      
        if (value === null) {
          return null;
        }
        else {
          var result = objectory.findInCache(value);
          if (result === null) {
            throw "External ref ${propertySchema.name} has not been fetched yet";
          }
          return result;
        }
      }
      return value;
    }
    else if (args.length == 1 && function_name.startsWith("set:")) {
      //synthetic setter
      var value = args[0];
      var property = function_name.replaceFirst("set:", "");
      propertySchema = schema.properties[property];
      if (propertySchema !== null) {
        if (propertySchema.link && !propertySchema.collection && value is RootPersistentObject){
          if (value !== null) {            
            if (value.id === null){        
              throw "Error setting link property $property. Link object must have not null id";
            }
            value = value.id;             
          }          
        }
        if (value is BasePersistentObject) {
          value = value.map;
        }
        if (value is PersistentList) {
          value = value.internalList;
        }        
        onValueChanging(property, value);
        this.map[property] = value;
        return;
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
  
  String get type() => "PersistentObjectBase";
  
  Future<PersistentObject> fetchLink(String property, [PropertySchema propertySchema, ObjectId objecId]) {  
    var completer = new Completer<PersistentObject>();
    if (propertySchema === null) {
      propertySchema = objectory.getSchema(type).properties[property];
    }          
    if (propertySchema === null) {
      throw "Property $property is not registered on class $type";
    }
    if (!propertySchema.link && !propertySchema.hasLinks){
      print(propertySchema);
      throw "Property $property is not of external ref type on class $type";
    }    
    var value;
    if (objecId !== null) {
      value = objecId;
    }    
    if (value === null) {
      value = map[property];
    }        
    if (value === null) {
      completer.complete(this);
    }
    else {      
      if (value is ObjectId){
        objectory.findOne(new ObjectoryQueryBuilder(propertySchema.type).id(value)).then((res){        
          completer.complete(this);
        });
      }     
      else {
        fetchRefsForListProperty(property,propertySchema,value).then((_)=>completer.complete(this));         
      }
    }  
    return completer.future;
  }
  
  Future fetchRefsForListProperty(String property, PropertySchema propertySchema, list) {  
    var futures = new List<Future>();
    if (propertySchema.embeddedObject) {  
      for (var each in new PersistentList(list, parent:this, pathToMe: property)) {
        futures.add(each.fetchLinks());
      }  
    }
    else {    
      for (var each in list) {
        futures.add(fetchLink(property,propertySchema,each));
      } 
    }   
    return Futures.wait(futures);
  }
 
  Future<RootPersistentObject> fetchLinks(){
    var futures = new List();
    for (var propertySchema in objectory.getSchema(type).properties.getValues()) {
      if (propertySchema.link || propertySchema.hasLinks) {
        futures.add(fetchLink(propertySchema.name, propertySchema));
      }          
    }
    Completer completer = new Completer<PersistentObject>();
    Futures.wait(futures).then((_) => completer.complete(this));
    return completer.future;    
  }  
}
abstract class RootPersistentObject extends BasePersistentObject{
   ObjectId id;
   
   void _initMap() {
     map["_id"] = null;
     super._initMap();
   }
   void remove() {
     objectory.remove(this);
   }
   
   void save() {
     objectory.save(this);
   }
}
abstract class EmbeddedPersistentObject extends BasePersistentObject{
  BasePersistentObject parent;
  String pathToMe;
  
  void setDirty(String fieldName){
    super.setDirty(fieldName);
    if (parent !== null) {
      parent.setDirty(pathToMe);
    }
  }  
}