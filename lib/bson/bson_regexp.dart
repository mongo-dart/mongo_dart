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
  BsonRegexp(this.pattern,[this.multiLine=false,this.caseInsensitive=false,this.dotAll=false,this.extended=false]):options=""{
    createOptionsString();    
    bsonPattern = new BsonCString(pattern,false);
    bsonOptions = new BsonCString(options,false);
  }
  
  get value()=>this;
  int get typeByte() => BSON.BSON_DATA_REGEXP;  
  byteLength()=>bsonPattern.byteLength()+bsonOptions.byteLength();
  unpackValue(Binary buffer){
    pattern = buffer.readCString();
    options = buffer.readCString();     
  }   
  createOptionsString(){
    var buffer = new StringBuffer();
    if (caseInsensitive === true){
      buffer.add("i");
    }
    if (multiLine === true){
      buffer.add("m");
    }    
    if (dotAll === true){
      buffer.add("s");
    }    
    if (extended === true){
      buffer.add("x");
    }    
    options = buffer.toString();
  }
  toString()=>"BsonRegexp('$pattern',options:'$options')";
  packValue(Binary buffer){     
     bsonPattern.packValue(buffer);
     bsonOptions.packValue(buffer);
  }  
}