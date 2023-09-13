import 'package:mongo_dart/mongo_dart_old.dart';
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

  var collectionName = 'update-many-array-filters';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var (ret, _, _, _) = await collection.insertMany([
    {
      '_id': 1,
      'grades': [95, 92, 90]
    },
    {
      '_id': 2,
      'grades': [98, 100, 102]
    },
    {
      '_id': 3,
      'grades': [95, 110, 100]
    }
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var (res, _) = await collection.updateMany(where.gte('grades', 100),
      ModifierBuilder().set(r'grades.$[element]', 100),
      arrayFilters: [
        {
          'element': {r'$gte': 100}
        }
      ]);

  print('Modified documents: ${res.nModified}'); // 2

  var findResult = await collection.find({}).toList();

  print('Last record grades, last element: '
      '${findResult.last['grades'].last}'); // 100;

  await cleanupDatabase();
}
