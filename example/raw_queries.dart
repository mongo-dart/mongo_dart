import 'package:mongo_dart/mongo_dart.dart';

main() async {
  Db db = new Db("mongodb://127.0.0.7/mongo_dart-test");
  DbCollection coll;
  ObjectId id;
  await db.open();
  print('connection open');
  coll = db.collection("simple_data");
  await coll.remove({});
  for (var n = 0; n < 1000; n++) {
    await coll.insert({"my_field": n, "str_field": "str_$n"});
  }
  var val = await coll.findOne({"my_field": 17});
  print("Filtered by my_field=17 $val");
  id = val["_id"];
  val = await coll.findOne({"_id": id});
  print("Filtered by _id=$id: $val");
  print("Removing doc with _id=$id");
  await coll.remove({"_id": id});
  val = await coll.findOne({"_id": id});
  print("Filtered by _id=$id: $val. There more no such a doc");
  print(
      "Filtered by {'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}");
  await coll.find({
    'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}
  }).forEach((v) => print(v));
  db.close();
}
