class ObjectoryQueryBuilder {
  
  ClassSchema schema;
  Map map;
  ObjectoryQueryBuilder(String className){
    schema = objectory.getSchema(className);
    map = new LinkedHashMap();
  }
  
  toString() => "ObjectoryQueryBuilder($map)";
  
  String get className() => schema.className;
  
  void testFieldName(String fieldName) {
    if (!schema.properties.containsKey(fieldName)) {
      throw "Unknown property $fieldName in class ${schema.className}";
    }
  }
  
  ObjectoryQueryBuilder eq(String fieldName,value){
    testFieldName(fieldName);
    map[fieldName] = value;
    return this;
  }
  
  ObjectoryQueryBuilder id(value){    
    map["_id"] = value;
    return this;
  }
  
  ObjectoryQueryBuilder ne(String fieldName, value){
    testFieldName(fieldName);
    map[fieldName] = {"\$ne":value};
    return this;
  }
  
  ObjectoryQueryBuilder gt(String fieldName,value){
    testFieldName(fieldName);
    map[fieldName] = {"\$gt":value};
    return this;
  }
  
  ObjectoryQueryBuilder lt(String fieldName,value){
    testFieldName(fieldName);
    map[fieldName] = {"\$lt":value};
    return this;
  }
  
  ObjectoryQueryBuilder gte(String fieldName,value){
    testFieldName(fieldName);
    map[fieldName] = {"\$gte":value};
    return this;
  }
  
  ObjectoryQueryBuilder lte(String fieldName,value){
    testFieldName(fieldName);
    map[fieldName] = {"\$lte":value};
    return this;
  }
  
  ObjectoryQueryBuilder all(String fieldName, List values){
    testFieldName(fieldName);
    map[fieldName] = {"\$all":values};
    return this;
  }
  
  ObjectoryQueryBuilder nin(String fieldName, List values){
    testFieldName(fieldName);
    map[fieldName] = {"\$nin":values};
    return this;
  }
  
  ObjectoryQueryBuilder oneFrom(String fieldName, List values){
    testFieldName(fieldName);
    map[fieldName] = {"\$in":values};
    return this;
  }
  
  ObjectoryQueryBuilder exists(String fieldName){
    testFieldName(fieldName);
    map[fieldName] = {"\$exists":true};
    return this;    
  }
  
  ObjectoryQueryBuilder notExists(String fieldName){
    testFieldName(fieldName);
    map[fieldName] = {"\$exists":false};
    return this;    
  }
  
  ObjectoryQueryBuilder mod(String fieldName, int value){
    testFieldName(fieldName);
    map[fieldName] = {"\$mod":[value,0]};
    return this;    
  }
  
  ObjectoryQueryBuilder match(String fieldName, String pattern,[bool multiLine, bool caseInsensitive, bool dotAll, bool extended]){
    testFieldName(fieldName);
    map[fieldName] = {'\$regex': new BsonRegexp(pattern,multiLine:multiLine, caseInsensitive:caseInsensitive,
        dotAll:dotAll,extended:extended)};
    return this;    
  }
  
  ObjectoryQueryBuilder range(String fieldName, min, max, [bool minInclude=true, bool maxInclude=true]){
    testFieldName(fieldName);
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
    map[fieldName] = rangeMap;
    return this;    
  }
  
  _internQueryMap(){
    if (!map.containsKey("query")){
      LinkedHashMap queryMap = new LinkedHashMap.from(map);
      map.clear();
      map["query"] = queryMap;
    }    
  }
  
  ObjectoryQueryBuilder sortBy(String fieldName, [bool descending=false]){
    testFieldName(fieldName);  
    _internQueryMap();
    if (!map.containsKey("orderby")){
      map["orderby"] = new LinkedHashMap();  
    }
    int order = 1;
    if (descending){
      order = -1;
    }
    map["orderby"][fieldName] = order;      
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
