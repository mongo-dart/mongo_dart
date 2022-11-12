import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var client = MongoClient(defaultUri);
  await client.connect();
  var db = client.db();
  await db.drop();

  Future cleanupDatabase(String collectionName) async {
    await db.dropCollection(collectionName);
    await client.close();
  }

  var collectionName = 'test-list-collections';
  await db.createCollection(collectionName);

  var ret = await db.getCollectionNames();
  var retInfo = await db.getCollectionInfos();

  if (ret.first != retInfo.first['name']) {
    print('Sorry, some error occured');
    return;
  }

  print(
      'First collection name: ${retInfo.first['name']}'); // 'test-list-collections';

  await cleanupDatabase(collectionName);
}
