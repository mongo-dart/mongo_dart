import 'package:mongo_dart/mongo_dart_old.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var db = Db(defaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'find-array';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany(<Map<String, dynamic>>[
    {
      '_id': 1,
      'admin': 'Tom',
      'state': 'active',
      'employers': [ObjectId.fromHexString('624f96b5210107050e87565a')]
    },
    {
      '_id': 2,
      'admin': 'William',
      'state': 'busy',
    },
    {
      '_id': 3,
      'admin': 'Liz',
      'state': 'on hold',
    },
    {
      '_id': 4,
      'admin': 'George',
      'state': 'active',
      'employers': [
        ObjectId.fromHexString('624f96b5210107050e875687'),
        ObjectId.fromHexString('624f96b5210107050e875692'),
        ObjectId.fromHexString('624f96b5210107050e875698')
      ]
    },
    {
      '_id': 5,
      'admin': 'Jim',
      'state': 'idle',
    },
    {
      '_id': 6,
      'admin': 'Laureen',
      'state': 'busy',
      'employers': [
        ObjectId.fromHexString('624f96b52101070512875687'),
        ObjectId.fromHexString('624f96b52101070512875692'),
        ObjectId.fromHexString('624f96b5210112050e875698')
      ]
    },
    {
      '_id': 7,
      'admin': 'John',
      'state': 'idle',
    }
  ]);

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection
      .find(where.eq(
          'employers', ObjectId.fromHexString('624f96b5210112050e875698')))
      .toList();
  print('Number of documents fetched: ${res.length}'); // 1
  print(
      'First document fetched: ${res.first['admin']} - ${res.first['state']}');
  // Laureen - busy

  await cleanupDatabase();
}
