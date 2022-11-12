import 'package:mongo_dart/src/mongo_client.dart';

void main() async {
  var client =
      MongoClient('mongodb://user:pencil@localhost/auth2?authSource=admin');
  await client.connect();
  var db = client.db();
  var collection = db.collection('test');
  print(await collection.find().toList());
  await client.close();
}
