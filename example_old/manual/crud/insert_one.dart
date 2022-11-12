import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var client = MongoClient(defaultUri);
  await client.connect();
  var db = client.db();
  Future cleanupDatabase() async {
    await client.close();
  }

  var collectionName = 'insert-one';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertOne(<String, dynamic>{
    '_id': 1,
    'name': 'Tom',
    'state': 'active',
    'rating': 100,
    'score': 5
  });

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.findOne();

  print('Fetched ${res?['name']}');
  // Tom

  await cleanupDatabase();
}
