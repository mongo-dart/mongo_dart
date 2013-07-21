import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
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
      return coll.findOne({"name":"c"})
    .then((v1){
      print("Record c: $v1");
      v1["value"] = 31;
      return coll.save(v1);
    }).then((_){   
      return coll.findOne({"name":"c"});
    }).then((v2){
      print("Record c after update: $v2");
      return new Future.value(null);
    });
  };

  fieldLevelUpdate() {
    DbCollection coll = db.collection('collection-for-save');
    coll.remove();
    List toInsert = [
                     {"name":"a", "value": 10},
                     {"name":"b", "value": 20},
                     {"name":"c", "value": 30},
                     {"name":"d", "value": 40}
                   ];
    coll.insertAll(toInsert);
    return coll.findOne({"name":"c"})
  .then((v1){
      print("Record c: $v1");
      v1["value"] = 31;
      coll.update(where.eq('name', 'c'), modify.set('value',31));
      return coll.findOne({"name":"c"});
    }).then((v2){
      print("Record c after field level update: $v2");
      return db.close();
    });
  };

  
  db.open().then((_) {
    return simpleUpdate();
  }).then((_)=>fieldLevelUpdate());
}