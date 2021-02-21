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

  var collectionName = 'update-one';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany([
    {
      '_id': 1,
      'member': 'abc123',
      'status': 'Pending',
      'points': 0,
      'misc1': 'note to self: confirm status',
      'misc2': 'Need to activate'
    },
    {
      '_id': 2,
      'member': 'xyz123',
      'status': 'D',
      'points': 59,
      'misc1': 'reminder: ping me at 100pts',
      'misc2': 'Some random comment'
    },
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.updateOne(where.eq('member', 'abc123'),
      ModifierBuilder().set('status', 'A').inc('points', 1),
      writeConcern: WriteConcern(w: 'majority', wtimeout: 5000));

  print('Modified documents: ${res.nModified}'); // 1

  var findResult = await collection.find(where.eq('member', 'abc123')).toList();

  print('Modified element status: '
      '"${findResult.first['status']}"'); // 'A';

  await cleanupDatabase();
}
