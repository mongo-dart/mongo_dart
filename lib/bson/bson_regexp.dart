class BsonRegexp extends BsonObject{
  String pattern;
  String options;
  bool multiLine;
  bool caseInsensitive;
  bool verbose;
  bool dotAll;
  bool unicodeMode;
  bool localeDependent;
  BsonRegexp(this.pattern,[this.multiLine,this.caseInsensitive,this.verbose,this.dotAll,this.unicodeMode,this.localeDependent]):options="";
  get value()=>this;
  int get typeByte() => BSON.BSON_DATA_REGEXP;  
  byteLength()=>pattern.length+1+options.length+1;
  unpackValue(Binary buffer){
    pattern = buffer.readCString();
    options = buffer.readCString();     
  }   
  createOptionsString(){
    options = "";  
  }
  toString()=>"BsonRegexp('$pattern',options:'$options')";
  packValue(Binary buffer){
     createOptionsString();
     buffer.writeCString(pattern.charCodes());
     buffer.writeCString(options.charCodes());     
  }  
}