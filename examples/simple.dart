#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:builtin");
main(){
  Db db = new Db("mongo-dart-test");
  MCollection coll;
  db.open().chain((c){
    print('connection open');
    coll = db.collection("simple_data");
    coll.remove();
    for (var n = 0; n<1000; n++){  
      coll.insert({"my_field":n,"str_field":"str_$n"});
    }      
    return coll.findOne({"my_field": 17});
  }).chain((val){
      print("Filtered by {'my_field': 17} $val");
      print("Filtered {'my_field': {'\$gt': 995}}:");
      return coll.find({'my_field': {'\$gt': 995}}).each((v)=>print(v));
  }).chain((val){
      print("Filtered by {'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}");
      return coll.find({'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}}).each((v)=>print(v));        
  }).then((dummy){    
      db.close();        
  });
}