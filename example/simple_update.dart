import 'package:mongo_dart/mongo_dart.dart';
main(){
  Db db = new Db('mongodb://127.0.0.1/mongo_dart-test');

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
    coll.findOne({"name":"c"}).then((v1){
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