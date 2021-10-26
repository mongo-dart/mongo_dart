import 'package:mongo_dart/mongo_dart.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var db = Db(DefaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'find-one-by-date';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany(<Map<String, dynamic>>[
    {
      '_id': 1,
      'name': 'Tom',
      'state': 'active',
      'timestamp': Timestamp(10, 12),
      'since': DateTime(2020, 10, 01),
    },
    {
      '_id': 2,
      'name': 'William',
      'state': 'busy',
      'timestamp': Timestamp(100, 112),
      'since': DateTime(2021, 10, 25)
    },
    {
      '_id': 3,
      'name': 'Liz',
      'state': 'on hold',
      'timestamp': Timestamp(200, 212),
      'since': DateTime(2021, 04, 05)
    },
    {
      '_id': 4,
      'name': 'George',
      'state': 'active',
      'timestamp': Timestamp(300, 312),
      'since': DateTime(2020, 12, 25)
    },
  ]);

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.findOne(where.lt('since', DateTime(2020, 10, 25)));

  if (res == null) {
    print('No document found');
  } else {
    print('Document fetched: '
        '${res['name']} - ${res['state']} - ${res['timestamp']}');
  } // Tom - active - Timestamp(10, 12)

  await cleanupDatabase();
}
