import 'package:mongo_dart/mongo_dart.dart';

main() async {
  Db db = new Db("mongodb://127.0.0.1/mongo_dart-test");
  ObjectId id;
  DbCollection coll;
  await db.open();
  print('connection open');
  coll = db.collection("simple_data");
  await coll.remove({});
  print('Packing data to insert into collection by Bson...');
  for (var n = 0; n < 1000; n++) {
    await coll.insert({"my_field": n, "str_field": "str_$n"});
  }
  print('Done. Now sending it to MongoDb...');
  await coll
      .find(where.gt("my_field", 995).sortBy('my_field'))
      .forEach((v) => print(v));
  var val = await coll.findOne(where.eq("my_field", 17));
  print("Filtered by my_field=17 $val");
  id = val["_id"];
  val = await coll.findOne(where.eq("my_field", 17).fields(['str_field']));
  print("findOne with fields clause 'str_field' $val");
  val = await coll.findOne(where.id(id));
  print("Filtered by _id=$id: $val");
  print("Removing doc with _id=$id");
  await coll.remove(where.id(id));
  val = await coll.findOne(where.id(id));
  print("Filtered by _id=$id: $val. There more no such a doc");
  await coll
      .find(where
          .gt("my_field", 995)
          .or(where.lt("my_field", 10))
          .and(where.match('str_field', '99')))
      .forEach((v) => print(v));
  print(
      "Filtered by (my_field gt 995 or my_field lt 10) and str_field like '99' ");
  await coll
      .find(where
          .inRange("my_field", 700, 703, minInclude: false)
          .sortBy('my_field'))
      .forEach((v) => print(v));
  print("Filtered by my_field gt 700, lte 703");
  await coll
      .find(where
          .inRange("my_field", 700, 703, minInclude: false)
          .sortBy('my_field'))
      .forEach((v) => print(v));
  print("Filtered by str_field match '^str_(5|7|8)17\$'");
  await coll
      .find(where
          .match('str_field', 'str_(5|7|8)17\$')
          .sortBy("str_field", descending: true)
          .sortBy("my_field"))
      .forEach((v) => print(v));
  var explanation = await coll.findOne(where
      .match('str_field', 'str_(5|7|8)17\$')
      .sortBy("str_field", descending: true)
      .sortBy("my_field")
      .explain());
  print("Query explained: $explanation");
  print(
      'Now where clause with jscript code: where("this.my_field % 100 == 35")');
  await coll
      .find(where.jsQuery("this.my_field % 100 == 35"))
      .forEach((v) => print(v));
  var count = coll.count(where.gt("my_field", 995));
  print('Count of records with my_field > 995: $count');
  var databases = await db.listDatabases();
  print('List of databases: $databases');
  var collections = await db.getCollectionNames();
  print('List of collections : $collections');
  var collectionInfos = await db.getCollectionInfos();
  print('List of collection\'s infos: $collectionInfos');
  await db.close();
}
