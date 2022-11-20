import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var client = MongoClient(defaultUri);
  await client.connect();
  //var db = client.db();

  Future cleanupDatabase() async {
    //await db.drop();
    await client.close();
  }

  print('Added collection has been correctly removed');

  await cleanupDatabase();
}
