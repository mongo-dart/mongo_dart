import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var db = Db('mongodb://user:pencil@localhost/auth2?authSource=admin');
  await db.open();
  var collection = db.collection('test');
  print(await collection.find().toList());
  await db.close();
}
