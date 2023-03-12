import 'package:mongo_dart/mongo_dart_old.dart' show CollationOptions, where;
import 'package:mongo_dart/src/command/query_and_write_operation_commands/find_operation/base/find_options.dart';
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

  var collectionName = 'delete-one-collation';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var (ret, _, _, _) = await collection.insertMany(<Map<String, dynamic>>[
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

  var (res, _) = await collection.deleteOne(
      <String, Object>{'category': 'cafe', 'status': 'a'},
      collation: CollationOptions('fr', strength: 1));

  print('Removed documents: ${res.nRemoved}');

  findResult = await collection.find().toList();

  print('First record category after deletion with collation: '
      '${findResult.first['category']}'); // 'cafE';

  await cleanupDatabase();
}
