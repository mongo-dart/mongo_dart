import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var client = MongoClient(defaultUri);
  await client.connect();
  final db = client.db();

  Future cleanupDatabase() async {
    await client.close();
  }

  var collectionName = 'union-with-suppliers';
  var collection2Name = 'union-with-warehouses';

  await db.dropCollection(collectionName);
  await db.dropCollection(collection2Name);

  var collection = db.collection(collectionName);
  var collection2 = db.collection(collection2Name);

  var (ret, _, _, _) = await collection.insertMany([
    {'_id': 1, 'supplier': "Aardvark and Sons", 'state': "Texas"},
    {'_id': 2, 'supplier': "Bears Run Amok.", 'state': "Colorado"},
    {'_id': 3, 'supplier': "Squid Mark Inc. ", 'state': "Rhode Island"},
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  (ret, _, _, _) = await collection2.insertMany([
    {'_id': 1, 'warehouse': "A", 'region': "West", 'state': "California"},
    {'_id': 2, 'warehouse': "B", 'region': "Central", 'state': "Colorado"},
    {'_id': 3, 'warehouse': "C", 'region': "East", 'state': "Florida"},
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  var aggregateResult = await collection.modernAggregate([
    {
      r'$project': {'state': 1, '_id': 0}
    },
    {
      r'$unionWith': {
        'coll': collection2Name,
        'pipeline': [
          {
            r'$project': {'state': 1, '_id': 0}
          }
        ]
      }
    }
  ]).toList();

  print('Documents number: ${aggregateResult.length}'); // 2

  for (var element in aggregateResult) {
    print(element);
  }
  // { state : Texas }
  // { state : Colorado }
  // { state : Rhode Island }
  // { state : California }
  // { state : Colorado }
  // { state : Florida }

  await cleanupDatabase();
}
