#import("../lib/mongo.dart");
#import("dart:builtin");
main(){  
  Db db = new Db("mongo-dart-test");
  var id;
  DbCollection coll;
  db.open().chain((c){
    print('connection open');
    coll = db.collection("simple_data");
    coll.remove();
    print('Packing data to insert into collection by Bson...');
    for (var n = 0; n<1000; n++){  
      coll.insert({"my_field":n,"str_field":"str_$n"});
    }      
    print('Done. Now sending it to MongoDb...');
    return coll.findOne(query().eq("my_field", 17));
  }).chain((val){
      print("Filtered by my_field=17 $val");
      id = val["_id"];
      return coll.findOne(query().id(id));
  }).chain((val){      
      print("Filtered by _id=$id: $val");    
      print("Removing doc with _id=$id");
      coll.remove(query().id(id));
      return coll.findOne(query().id(id));
  }).chain((val){      
      print("Filtered by _id=$id: $val. There more no such a doc");
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
  }).chain((explanation){
    print("Query explained: $explanation");
    print('Now where clause with jscript code: where("this.my_field % 100 == 35")');
    print(query().where("this.my_field == 517"));
    return coll.find(query().where("this.my_field % 100 == 35")).each((v)=>print(v));
  }).then((v){
     db.close();        
  });
}