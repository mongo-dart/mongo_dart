SelectorBuilder query(){
  return new SelectorBuilder();
}
class SelectorBuilder<K,V> extends _MapProxy<K,V>{
  toString()=>"SelectorBuilder($map)";
  SelectorBuilder eq(String fieldName,value){
    map[fieldName] = value;
    return this;
  }
  SelectorBuilder id(value){
    map["_id"] = value;
    return this;
  }
  SelectorBuilder ne(String fieldName, value){
    map[fieldName] = {"\$ne":value};
    return this;
  }
  SelectorBuilder gt(String fieldName,value){
    map[fieldName] = {"\$gt":value};
    return this;
  }
  SelectorBuilder lt(String fieldName,value){
    map[fieldName] = {"\$lt":value};
    return this;
  }
  SelectorBuilder gte(String fieldName,value){
    map[fieldName] = {"\$gte":value};
    return this;
  }
  SelectorBuilder lte(String fieldName,value){    
    map[fieldName] = {"\$lte":value};
    return this;
  }
  SelectorBuilder all(String fieldName, List values){
    map[fieldName] = {"\$all":values};
    return this;
  }
  SelectorBuilder nin(String fieldName, List values){
    map[fieldName] = {"\$nin":values};
    return this;
  }
  SelectorBuilder oneFrom(String fieldName, List values){
    map[fieldName] = {"\$in":values};
    return this;
  } 
  SelectorBuilder exists(String fieldName){
    map[fieldName] = {"\$exists":true};
    return this;    
  }
  SelectorBuilder notExists(String fieldName){
    map[fieldName] = {"\$exists":false};
    return this;    
  }
  SelectorBuilder mod(String fieldName, int value){
    map[fieldName] = {"\$mod":[value,0]};
    return this;    
  }
  SelectorBuilder match(String fieldName, String pattern,[bool multiLine, bool caseInsensitive, bool dotAll, bool extended]){    
    map[fieldName] = {'\$regex': new BsonRegexp(pattern,multiLine:multiLine, caseInsensitive:caseInsensitive,
        dotAll:dotAll,extended:extended)};
    return this;    
  }
  SelectorBuilder range(String fieldName, min, max, [bool minInclude=true, bool maxInclude=true]){
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
  SelectorBuilder sortBy(String fieldName, [bool descending=false]){
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
  SelectorBuilder comment(String commentStr){
    _internQueryMap();  
    map["\$comment"] = commentStr;      
    return this;    
  }
  SelectorBuilder explain(){
    _internQueryMap();  
    map["\$explain"] = true;      
    return this;    
  }
  SelectorBuilder snapshot(){
    _internQueryMap();  
    map["\$snapshot"] = true;      
    return this;    
  }
  SelectorBuilder showDiskLoc(){
    _internQueryMap();  
    map["\$showDiskLoc"] = true;      
    return this;    
  }
  SelectorBuilder returnKey(){
    _internQueryMap();  
    map["\$sreturnKey"] = true;      
    return this;    
  }  
  SelectorBuilder where(String javaScriptCode){
    map["\$where"] = new BsonCode(javaScriptCode);
    return this;
  }
}
