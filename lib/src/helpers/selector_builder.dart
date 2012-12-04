part of mongo_dart;

@deprecated
SelectorBuilder query(){
  return new SelectorBuilder();
}

SelectorBuilder get where => new SelectorBuilder();

class _ExtParams {
  int skip = 0;
  int limit = 0;
  Map fields;
}
class SelectorBuilder{
  Map map = {};
  _ExtParams extParams = new _ExtParams();

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
  SelectorBuilder match(String fieldName, String pattern,{bool multiLine, bool caseInsensitive, bool dotAll, bool extended}){
    map[fieldName] = {'\$regex': new BsonRegexp(pattern,multiLine:multiLine, caseInsensitive:caseInsensitive,
        dotAll:dotAll,extended:extended)};
    return this;
  }
  @deprecated
  SelectorBuilder range(String fieldName, min, max, {bool minInclude: true, bool maxInclude: true}){
    return inRange(fieldName, min, max, minInclude: minInclude, maxInclude: maxInclude);
  }

  SelectorBuilder inRange(String fieldName, min, max, {bool minInclude: true, bool maxInclude: false}) {
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
  SelectorBuilder sortBy(String fieldName, {bool descending: false}){
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
  @deprecated
  SelectorBuilder where(String javaScriptCode){
    map["\$where"] = new BsonCode(javaScriptCode);
    return this;
  }

  SelectorBuilder jsQuery(String javaScriptCode){
    map["\$where"] = new BsonCode(javaScriptCode);
    return this;
  }


  SelectorBuilder fields(List<String> fields) {
     if (extParams.fields != null) {
       throw 'Fields parameter may be set only once for selector';
     }
     extParams.fields = {};
     for (var field in fields) {
       extParams.fields[field] = 1;
     }
     return this;
  }
  SelectorBuilder excludeFields(List<String> fields) {
    if (extParams.fields != null) {
      throw 'Fields parameter may be set only once for selector';
    }
    extParams.fields = {};
    for (var field in fields) {
      extParams.fields[field] = -1;
    }
    return this;
  }

  SelectorBuilder limit(int limit) {
    extParams.limit = limit;
    return this;
  }

  SelectorBuilder skip(int skip) {
    extParams.skip = skip;
    return this;
  }

  SelectorBuilder raw(Map rawSelector) {
    map = rawSelector;
    return this;
  }

}
