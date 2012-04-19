#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:builtin");

main(){
  Db db = new Db("mongo-dart-blog");
  print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
  db.open().chain((c){  
    DbCollection collection = db.collection('test-types');
    collection.remove();  
    collection.insert({
      'array':[1,2,3], 
      'string':'hello', 
      'hash':{'a':1, 'b':2}, 
      'date':new Date.now(),          // Stores only milisecond resolution
      'oid':new ObjectId(),
      'binary':new Binary.from([0x23,0x24,0x25]),
      'int':42,
      'float':33.3333,
      'regexp': new BsonRegexp(".?dim"),
      'boolean':true,
      'where':new BsonCode('this.x == 3'),
      'null':null
    });
    return collection.findOne();
  }).then((v){    
    print(v);  
    db.close();  
  });  
}  