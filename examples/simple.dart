#import("../lib/mongo.dart");
#import("dart:builtin");
main(){
  Db db = new Db("mongo-dart-test");
  db.open().then((connOpened){
    print('connection open');
    MCollection coll = db.collection("simple_data");
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
  });

}