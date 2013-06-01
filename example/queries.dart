import 'package:mongo_dart/mongo_dart.dart';
main(){
  Db db = new Db("mongodb://127.0.0.1/mongo_dart-test");
  ObjectId id;
  DbCollection coll;
  db.open().then((c){
    print('connection open');
    coll = db.collection("simple_data");
    coll.remove();
    print('Packing data to insert into collection by Bson...');
    for (var n = 0; n<1000; n++){
      coll.insert({"my_field":n,"str_field":"str_$n"});
    }
    print('Done. Now sending it to MongoDb...');    
    return coll.find(where.gt("my_field", 995).sortBy('my_field')).each((v)=>print(v));
  }).then((val){   
    return coll.findOne(where.eq("my_field", 17));
  }).then((val){
    print("Filtered by my_field=17 $val");
    id = val["_id"];
    return coll.findOne(where.eq("my_field", 17).fields(['str_field']));
  }).then((val){
      print("findOne with fields clause 'str_field' $val");
      return coll.findOne(where.id(id));
  }).then((val){
      print("Filtered by _id=$id: $val");
      print("Removing doc with _id=$id");
      coll.remove(where.id(id));
      return coll.findOne(where.id(id));
  }).then((val){
      print("Filtered by _id=$id: $val. There more no such a doc");
      return coll.find(where.gt("my_field", 995).or(where.lt("my_field", 10)).and(where.match('str_field', '99'))).each((v)=>print(v));

  }).then((val){
    print("Filtered by (my_field gt 995 or my_field lt 10) and str_field like '99' ");
    return coll.find(
      where.inRange("my_field", 700, 703, minInclude: false).sortBy('my_field')
        ).each((v)=>print(v));
      
      return coll.find(where.gt("my_field", 995)).each((v)=>print(v));
  }).then((val){
    print("Filtered by my_field gt 700, lte 703");
    return coll.find(
      where.inRange("my_field", 700, 703, minInclude: false).sortBy('my_field')
        ).each((v)=>print(v));
  }).then((val){
      print("Filtered by str_field match '^str_(5|7|8)17\$'");
      return coll.find(
        where.match('str_field', 'str_(5|7|8)17\$').sortBy("str_field",descending:true).sortBy("my_field")
          ).each((v)=>print(v));
  }).then((val){
    return coll.findOne(
      where.match('str_field', 'str_(5|7|8)17\$').sortBy("str_field",descending:true).sortBy("my_field").explain());
  }).then((explanation){
    print("Query explained: $explanation");
    print('Now where clause with jscript code: where("this.my_field % 100 == 35")');
    print(where.jsQuery("this.my_field == 517"));
    return coll.find(where.jsQuery("this.my_field % 100 == 35")).each((v)=>print(v));
  }).then((v) {
    return coll.count(where.gt("my_field", 995));
  }).then((count){
    print('Count of records with my_field > 995: $count');
    db.close();
  });
}