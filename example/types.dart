import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var db = Db('mongodb://127.0.0.1/mongo_dart-blog');
  await db.open();
  var collection = db.collection('test-types');
  await collection.remove({});
  await collection.insert({
    'array': [1, 2, 3],
    'string': 'hello',
    'hash': {'a': 1, 'b': 2},
    'date': DateTime.now(), // Stores only milisecond resolution
    'oid': ObjectId(),
    'binary': BsonBinary.from([0x23, 0x24, 0x25]),
    'int': 42,
    'float': 33.3333,
    'regexp': BsonRegexp('.?dim'),
    'boolean': true,
    'where': BsonCode('this.x == 3'),
    'null': null
  });
  var v = await collection.findOne();
  print(v);
  await db.close();
}
