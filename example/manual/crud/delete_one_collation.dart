import 'package:mongo_dart/mongo_dart.dart'
    show CollationOptions, Db, FindOptions, where;

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

  var collectionName = 'delete-one';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany(<Map<String, dynamic>>[
    {'_id': 1, 'category': 'café', 'status': 'A'},
    {'_id': 2, 'category': 'cafE', 'status': 'a'},
    {'_id': 3, 'category': 'cafe', 'status': 'a'},
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var findResult = await collection
      .modernFind(selector: where.eq('category', 'cafe').eq('status', 'a'))
      .toList();

  print('First record category without collation before deletion: '
      '${findResult.first['category']}'); // 'cafe';

  findResult = await collection
      .modernFind(
          selector: where.eq('category', 'cafe').eq('status', 'a'),
          findOptions:
              FindOptions(collation: CollationOptions('fr', strength: 1)))
      .toList();

  print('First record category with collation before deletion: '
      '${findResult.first['category']}'); // 'café';

  var res = await collection.deleteOne(
      <String, Object>{'category': 'cafe', 'status': 'a'},
      collation: CollationOptions('fr', strength: 1));

  print('Removed documents: ${res.nRemoved}');

  findResult = await collection.find().toList();

  print('First record category after deletion with collation: '
      '${findResult.first['category']}'); // 'cafE';

  await cleanupDatabase();
}
