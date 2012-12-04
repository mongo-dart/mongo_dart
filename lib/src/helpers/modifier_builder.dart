part of mongo_dart;


ModifierBuilder get modify => new ModifierBuilder();

class ModifierBuilder{
  Map map = {};

  toString()=>"ModifierBuilder($map)";
  Map _pair2Map(String fieldName, value) {
    var res = {};
    res[fieldName] = value;
    return res;
  }
  ModifierBuilder inc(String fieldName,value) {
    map['\$inc'] = _pair2Map(fieldName,value);
    return this;
  }

  ModifierBuilder set(String fieldName,value) {
    map['\$set'] = _pair2Map(fieldName,value);
    return this;
  }

  ModifierBuilder unset(String fieldName) {
    map['\$unset'] = _pair2Map(fieldName, 1);
    return this;
  }

  ModifierBuilder push(String fieldName, value) {
    map['\$push'] = _pair2Map(fieldName, value);
    return this;
  }

}
