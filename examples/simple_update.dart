#import("../lib/mongo.dart");
#import("dart:builtin");
main(){
  Db db = new Db('mongo-dart-test');
 
  simpleUpdate() {
    DbCollection coll = db.collection('collection-for-save');
    coll.remove();  
    List toInsert = [
                     {"name":"a", "value": 10},
                     {"name":"b", "value": 20},
                     {"name":"c", "value": 30},
                     {"name":"d", "value": 40}
                   ];
    coll.insertAll(toInsert);
    coll.findOne({"name":"c"}).chain((v1){
      print("Record c: $v1");
      v1["value"] = 31;    
      coll.save(v1);
      return coll.findOne({"name":"c"});
    }).then((v2){
      print("Record c after update: $v2");
      db.close();
    });   
  };
  
  db.open().then((c)=>simpleUpdate()); 
}