#library("objectory_query");
#import("schema.dart");
#import("../bson/bson.dart");
#import("objectory_base.dart");

class ObjectoryQueryBuilder {  
  ClassSchema schema;
  Map map;
  ObjectoryQueryBuilder(String className){
    schema = objectory.getSchema(className);
    map = new LinkedHashMap();
  }
  
  toString() => "ObjectoryQueryBuilder($map)";
  
  String get className() => schema.className;
  
  void testPropertyName(String propertyName) {
    var propertyChain = propertyName.split('.');
    var currentProperty = propertyChain[0]; 
    var propertySchema = schema.properties[currentProperty];
    if (propertySchema === null) {
      throw "Unknown property $currentProperty in class ${schema.className}";
    }
    if (propertyChain.length > 1) {
      if (!propertySchema.embeddedObject)
      {  
        throw "$currentProperty is not an embedded object in class ${schema.className}. Dot notation of $propertyName is not applicable";
      }
      propertyChain.removeRange(0, 1);
      currentProperty = Strings.join(propertyChain,'.');
      new ObjectoryQueryBuilder(propertySchema.type).testPropertyName(currentProperty);
    }
  }
  
  ObjectoryQueryBuilder eq(String propertyName,value){
    testPropertyName(propertyName);
    map[propertyName] = value;
    return this;
  }
  
  ObjectoryQueryBuilder id(value){    
    map["_id"] = value;
    return this;
  }
  
  ObjectoryQueryBuilder ne(String propertyName, value){
    testPropertyName(propertyName);
    map[propertyName] = {"\$ne":value};
    return this;
  }
  
  ObjectoryQueryBuilder gt(String propertyName,value){
    testPropertyName(propertyName);
    map[propertyName] = {"\$gt":value};
    return this;
  }
  
  ObjectoryQueryBuilder lt(String propertyName,value){
    testPropertyName(propertyName);
    map[propertyName] = {"\$lt":value};
    return this;
  }
  
  ObjectoryQueryBuilder gte(String propertyName,value){
    testPropertyName(propertyName);
    map[propertyName] = {"\$gte":value};
    return this;
  }
  
  ObjectoryQueryBuilder lte(String propertyName,value){
    testPropertyName(propertyName);
    map[propertyName] = {"\$lte":value};
    return this;
  }
  
  ObjectoryQueryBuilder all(String propertyName, List values){
    testPropertyName(propertyName);
    map[propertyName] = {"\$all":values};
    return this;
  }
  
  ObjectoryQueryBuilder nin(String propertyName, List values){
    testPropertyName(propertyName);
    map[propertyName] = {"\$nin":values};
    return this;
  }
  
  ObjectoryQueryBuilder oneFrom(String propertyName, List values){
    testPropertyName(propertyName);
    map[propertyName] = {"\$in":values};
    return this;
  }
  
  ObjectoryQueryBuilder exists(String propertyName){
    testPropertyName(propertyName);
    map[propertyName] = {"\$exists":true};
    return this;    
  }
  
  ObjectoryQueryBuilder notExists(String propertyName){
    testPropertyName(propertyName);
    map[propertyName] = {"\$exists":false};
    return this;    
  }
  
  ObjectoryQueryBuilder mod(String propertyName, int value){
    testPropertyName(propertyName);
    map[propertyName] = {"\$mod":[value,0]};
    return this;    
  }
  
  ObjectoryQueryBuilder match(String propertyName, String pattern,[bool multiLine, bool caseInsensitive, bool dotAll, bool extended]){
    testPropertyName(propertyName);
    map[propertyName] = {'\$regex': new BsonRegexp(pattern,multiLine:multiLine, caseInsensitive:caseInsensitive,
        dotAll:dotAll,extended:extended)};
    return this;    
  }
  
  ObjectoryQueryBuilder range(String propertyName, min, max, [bool minInclude=true, bool maxInclude=true]){
    testPropertyName(propertyName);
    Map rangeMap = {};
    if (minInclude){
      rangeMap["\$gte"] = min;
    }
    else{
      rangeMap["\$gt"] = min;
    }
    if (maxInclude){
      rangeMap["\$lte"] = max;
    }
    else{
      rangeMap["\$gt"] = max;
    }
    map[propertyName] = rangeMap;
    return this;    
  }
  
  _internQueryMap(){
    if (!map.containsKey("query")){
      LinkedHashMap queryMap = new LinkedHashMap.from(map);
      map.clear();
      map["query"] = queryMap;
    }    
  }
  
  ObjectoryQueryBuilder sortBy(String propertyName, [bool descending=false]){
    testPropertyName(propertyName);  
    _internQueryMap();
    if (!map.containsKey("orderby")){
      map["orderby"] = new LinkedHashMap();  
    }
    int order = 1;
    if (descending){
      order = -1;
    }
    map["orderby"][propertyName] = order;      
    return this;    
  }
  
  ObjectoryQueryBuilder comment(String commentStr){
    _internQueryMap();  
    map["\$comment"] = commentStr;      
    return this;    
  }
  
  ObjectoryQueryBuilder explain(){
    _internQueryMap();  
    map["\$explain"] = true;      
    return this;    
  }
  
  ObjectoryQueryBuilder snapshot(){
    _internQueryMap();  
    map["\$snapshot"] = true;      
    return this;    
  }
  
  ObjectoryQueryBuilder showDiskLoc(){
    _internQueryMap();  
    map["\$showDiskLoc"] = true;      
    return this;    
  }
  
  ObjectoryQueryBuilder returnKey(){
    _internQueryMap();  
    map["\$sreturnKey"] = true;      
    return this;    
  }
  
  ObjectoryQueryBuilder where(String javaScriptCode){
    map["\$where"] = new BsonCode(javaScriptCode);
    return this;
  }
}
