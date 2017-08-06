import 'package:mongo_dart/mongo_dart.dart';

main() async {
  Db db = new Db('mongodb://127.0.0.1/mongo_dart-test');
  await db.open();
  ///// Simple update
  DbCollection coll = db.collection('collection-for-save');
  await coll.remove({});
  List toInsert = [
    {"name": "a", "value": 10},
    {"name": "b", "value": 20},
    {"name": "c", "value": 30},
    {"name": "d", "value": 40}
  ];
  await coll.insertAll(toInsert);
  var v1 = await coll.findOne({"name": "c"});
  print("Record c: $v1");
  v1["value"] = 31;
  await coll.save(v1);
  var v2 = await coll.findOne({"name": "c"});
  print("Record c after update: $v2");

  /////// Field level update
  coll = db.collection('collection-for-save');
  await coll.remove({});
  toInsert = [
    {"name": "a", "value": 10},
    {"name": "b", "value": 20},
    {"name": "c", "value": 30},
    {"name": "d", "value": 40}
  ];
  await coll.insertAll(toInsert);
  v1 = await coll.findOne({"name": "c"});
  print("Record c: $v1");
  coll.update(where.eq('name', 'c'), modify.set('value', 31));
  v2 = await coll.findOne({"name": "c"});
  print("Record c after field level update: $v2");

  //// Field level increment

  coll = db.collection('collection-for-save');
  await coll.remove({});
  toInsert = [
    {"name": "a", "value": 10},
    {"name": "b", "value": 20},
    {"name": "c", "value": 30},
    {"name": "d", "value": 40}
  ];
  await coll.insertAll(toInsert);
  v1 = await coll.findOne({"name": "c"});
  print("Record c: $v1");
  coll.update(where.eq('name', 'c'), modify.inc('value', 1));
  v2 = await coll.findOne({"name": "c"});
  print("Record c after field level increment by one: $v2");
  await db.close();
}
