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

  var collectionName = 'find-modify-collation';
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

   var res = await collection.modernFindAndModify(
            query: where.eq('category', 'cafe').eq('status', 'a'),
            sort: <String, dynamic>{'category': 1},
            update: ModifierBuilder().set('status', 'updated'),
            findAndModifyOptions: FindAndModifyOptions(
                collation: CollationOptions('fr', strength: 1)));

  print('Updated document: ${res.lastErrorObject.updatedExisting}'); // true

  print('Modified element original category: '
      '${res.value['category']}'); // 'café';

  await cleanupDatabase();
}
