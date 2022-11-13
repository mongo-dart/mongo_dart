import 'package:mongo_dart/src/mongo_client.dart';

final String mongoDbUri =
//    'mongodb://test:test@ds031477.mongolab.com:31477/dart';
    'mongodb://user:pencil@localhost/auth1';
void main() async {
//  Db db = new Db(mongoDbUri, 'test scram sha1');
//
//  await db.open();
//  print(await db.collection('test').find().toList());
//  await db.close();
  var client = MongoClient('mongodb://ds031477.mongolab.com:31477/dart');
  await client.connect();
  final db = client.db();

  await db.authenticate('test', 'test', db.server);
  var collection = db.collection('testAuthenticationWithUri');
  await collection.remove({});
  await collection.insert({'a': 1});
  await collection.insert({'a': 2});
  await collection.insert({'a': 3});
  await collection.findOne();
  await client.close();
}
