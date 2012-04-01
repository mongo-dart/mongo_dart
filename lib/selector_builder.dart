SelectorBuilder sel(){
  return new SelectorBuilder();
}
class SelectorBuilder<K,V> extends _MapProxy<K,V>{  
  SelectorBuilder eq(String fieldName, var value){
    map["query"][fieldName] = value;
    return this;
  }
  SelectorBuilder ne(String fieldName, var value){
    map["query"][fieldName] = {"\$ne":value};
    return this;
  }
  SelectorBuilder gt(String fieldName, var value){
    map["query"][fieldName] = {"\$gt":value};
    return this;
  }
  SelectorBuilder lt(String fieldName, var value){
    map["query"][fieldName] = {"\$lt":value};
    return this;
  }
  SelectorBuilder gte(String fieldName, var value){
    map["query"][fieldName] = {"\$gte":value};
    return this;
  }
  SelectorBuilder lte(String fieldName, var value){    
    map["query"][fieldName] = {"\$lte":value};
    return this;
  }
  SelectorBuilder all(String fieldName, List values){
    map["query"][fieldName] = {"\$all":values};
    return this;
  }
  SelectorBuilder exists(String fieldName){
    map["query"][fieldName] = {"\$exists":true};
    return this;    
  }
  SelectorBuilder notExists(String fieldName){
    map["query"][fieldName] = {"\$exists":false};
    return this;    
  }
  SelectorBuilder mod(String fieldName, int value){
    map["query"][fieldName] = {"\$mod":[value,0]};
    return this;    
  }  
}
