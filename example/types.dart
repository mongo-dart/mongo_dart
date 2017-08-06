import 'package:mongo_dart/mongo_dart.dart';

main() async {
  Db db = new Db("mongodb://127.0.0.1/mongo_dart-blog");
  await db.open();
  DbCollection collection = db.collection('test-types');
  await collection.remove({});
  await collection.insert({
    'array': [1, 2, 3],
    'string': 'hello',
    'hash': {'a': 1, 'b': 2},
    'date': new DateTime.now(), // Stores only milisecond resolution
    'oid': new ObjectId(),
    'binary': new BsonBinary.from([0x23, 0x24, 0x25]),
    'int': 42,
    'float': 33.3333,
    'regexp': new BsonRegexp(".?dim"),
    'boolean': true,
    'where': new BsonCode('this.x == 3'),
    'null': null
  });
  var v = await collection.findOne();
  print(v);
  await db.close();
}
