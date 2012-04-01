#import("../lib/mongo.dart");
#import("dart:builtin");
main(){
  Db db = new Db("mongo-dart-test");
  DbCollection coll;
  db.open().chain((c){
    print('connection open');
    coll = db.collection("simple_data");
    coll.remove();
    for (var n = 0; n<1000; n++){  
      coll.insert({"my_field":n,"str_field":"str_$n"});
    }      
    return coll.findOne(query().eq("my_field", 17));
  }).chain((val){
      print("Filtered by my_field= 17} $val");
      print("Filtered by my_field gt 995}}:");
      return coll.find(query().gt("my_field", 995)).each((v)=>print(v));
  }).chain((val){    
    print("Filtered by my_field gt 700, lte 703");
    return coll.find(
      query().range("my_field", 700, 703, minInclude: false)
        ).each((v)=>print(v));
  }).chain((val){
      print("Filtered by str_field match '^str_(5|7|8)17\$'");
      return coll.find(
        query().match('str_field', 'str_(5|7|8)17\$').sortBy("str_field",descending:true).sortBy("my_field")
          ).each((v)=>print(v));
  }).chain((val){
    return coll.findOne(
      query().match('str_field', 'str_(5|7|8)17\$').sortBy("str_field",descending:true).sortBy("my_field").explain());
  }).then((explanation){
     print("Query explained: $explanation");
     db.close();        
  });
}