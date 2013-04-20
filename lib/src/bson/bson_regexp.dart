part of bson;
class BsonRegexp extends BsonObject{
  String pattern;
  String options;
  BsonCString bsonPattern;
  BsonCString bsonOptions;

  bool multiLine;
  bool caseInsensitive;
  bool verbose;
  bool dotAll;
  bool extended;
  BsonRegexp(this.pattern,{this.multiLine: false,this.caseInsensitive: false,this.dotAll: false,this.extended: false,this.options: ''}){
    createOptionsString();
    bsonPattern = new BsonCString(pattern,false);
    bsonOptions = new BsonCString(options,false);
  }
  get value=>this;
  int get typeByte => BSON.BSON_DATA_REGEXP;
  byteLength()=>bsonPattern.byteLength()+bsonOptions.byteLength();
  unpackValue(BsonBinary buffer){
    pattern = buffer.readCString();
    options = buffer.readCString();
  }
  createOptionsString(){
    if (options != '') {
      return;
    }
    var buffer = new StringBuffer();
    if (caseInsensitive == true){
      buffer.write("i");
    }
    if (multiLine == true){
      buffer.write("m");
    }
    if (dotAll == true){
      buffer.write("s");
    }
    if (extended == true){
      buffer.write("x");
    }
    options = buffer.toString();
  }
  toString()=>"BsonRegexp('$pattern',options:'$options')";
  packValue(BsonBinary buffer){
     bsonPattern.packValue(buffer);
     bsonOptions.packValue(buffer);
  }
  toJson() => {'\$regex': pattern,'\$oid': options};
}