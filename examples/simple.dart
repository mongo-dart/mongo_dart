#import("../lib/mongo.dart");
#import("dart:builtin");
main(){
  Db db = new Db("mongo-dart-test");
  //Db db = new Db("mongo-dart-test", new ServerConfig("127.0.0.1",27017));
  db.open();
  MCollection coll = db.collection("simple_data");
  // Remove all existing data from collection;
  coll.remove();
  for (var n = 0; n<1000; n++){  
    coll.insert({"my_field":n});
  }
  
  coll.findOne({"my_field": 17}).then((val){
    print("Filtered by value: $val");     
  });
  
  coll.find({"my_field": {"\$gt": 985}}).each((v)=>print(v)).then((dummy){    
    db.close();
  });
    
}