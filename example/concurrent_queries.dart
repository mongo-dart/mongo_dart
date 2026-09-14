import 'package:mongo_dart/mongo_dart.dart';

const concurrentQueries = 3;
const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';
// Set the correct Atlas info
const defaultUri2 = 'mongodb+srv://-user-:-password-@-address-.mongodb.net/'
    '?appName=ConcurrentQueries&authMechanism=SCRAM-SHA-1&retryWrites=true'
    '&w=majority&safeAtlas=true';

void main() async {
  final db = await Db.create(defaultUri2);
  await db.open(secure: true);
  final collection = db.collection('test_collection');

  var result = await Future.wait([
    collection.find().toList(),
    collection.find().toList(),
    collection.find().toList(),
    collection.find().toList(),
    collection.find().toList(),
  ]);
  print(" -");
  print(result);

  await db.close();
}
