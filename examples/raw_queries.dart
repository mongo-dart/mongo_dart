#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:builtin");
main(){
  Db db = new Db("mongo-dart-test");
  DbCollection coll;
  ObjectId id;
  db.open().chain((c){
    print('connection open');
    coll = db.collection("simple_data");
    coll.remove();
    for (var n = 0; n<1000; n++){  
      coll.insert({"my_field":n,"str_field":"str_$n"});
    }      
    return coll.findOne({"my_field": 17});
  }).chain((val){
      print("Filtered by my_field=17 $val");
      id = val["_id"];
      return coll.findOne({"_id":id});
  }).chain((val){      
      print("Filtered by _id=$id: $val");    
      print("Removing doc with _id=$id");
      coll.remove({"_id":id});
      return coll.findOne({"_id":id});
  }).chain((val){      
      print("Filtered by _id=$id: $val. There more no such a doc");
      print("Filtered by {'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}");
      return coll.find({'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}}).each((v)=>print(v));        
  }).then((dummy){    
      db.close();        
  });
}