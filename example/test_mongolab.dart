import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

final String mongoDbUri =
//    'mongodb://test:test@ds031477.mongolab.com:31477/dart';
    'mongodb://user:pencil@localhost/auth1';
main() async {
//  Db db = new Db(mongoDbUri, 'test scram sha1');
//
//  await db.open();
//  print(await db.collection('test').find().toList());
//  await db.close();

  var db = new Db('mongodb://ds031477.mongolab.com:31477/dart');
  await db.open();
  await db.authenticate('test', 'test');
  DbCollection collection = db.collection('testAuthenticationWithUri');
  await collection.remove();
  await collection.insert({"a": 1});
  await collection.insert({"a": 2});
  await collection.insert({"a": 3});
  await collection.findOne();
  await db.close();
}
