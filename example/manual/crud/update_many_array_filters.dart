import 'package:mongo_dart/mongo_dart.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  Db db;

  Future initializeDatabase() async {
    db = Db(DefaultUri);
    await db.open();
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  await initializeDatabase();
  if (db.masterConnection == null ||
      !db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'update-many-array-filters';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany([
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

  var res = await collection.updateMany(where.gte('grades', 100),
      ModifierBuilder().set(r'grades.$[element]', 100),
      arrayFilters: [
        {
          'element': {r'$gte': 100}
        }
      ]);

  print('Modified documents: ${res.nModified}'); // 2

  var findResult = await collection.find().toList();

  print('Last record grades, last element: '
      '${findResult.last['grades'].last}'); // 100;

  await cleanupDatabase();
}
