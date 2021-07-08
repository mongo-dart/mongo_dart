import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var db = Db('mongodb://127.0.0.1/mongo_dart-test');
  DbCollection coll;
  ObjectId? id;
  await db.open();
  print('connection open');
  coll = db.collection('simple_data');
  await coll.deleteMany({});
  for (var n = 0; n < 1000; n++) {
    await coll.insert({'my_field': n, 'str_field': 'str_$n'});
  }
  var val = await coll.findOne({'my_field': 17});
  print('Filtered by my_field=17 $val');
  id = val?['_id'] as ObjectId?;
  if (id == null) {
    print('Id not detected');
    await db.close();
    return;
  }
  val = await coll.findOne({'_id': id});
  print('Filtered by _id=$id: $val');
  print('Removing doc with _id=$id');
  await coll.deleteOne({'_id': id});
  val = await coll.findOne({'_id': id});
  print('Filtered by _id=$id: $val. There more no such a doc');
  print(
      "Filtered by {'str_field': {'\$regex': new BsonRegexp('^str_(5|7|8)17\$')}");
  await coll.find({
    'str_field': {'\$regex': BsonRegexp('^str_(5|7|8)17\$')}
  }).forEach((v) => print(v));
  await db.close();
}
