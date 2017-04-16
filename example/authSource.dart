import 'package:mongo_dart/mongo_dart.dart';

main() async {
  var db = new Db('mongodb://user:pencil@localhost/auth2?authSource=admin');
  await db.open();
  DbCollection collection = db.collection('test');
  print(await collection.find().toList());
  await db.close();
}
