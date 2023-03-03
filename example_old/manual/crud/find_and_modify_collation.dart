import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/find_one_and_update/base/find_one_and_update_options.dart';
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

  var collectionName = 'find-modify-collation';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var (ret,_,_,_) = await collection.insertMany(<Map<String, dynamic>>[
    {'_id': 1, 'category': 'café', 'status': 'A'},
    {'_id': 2, 'category': 'cafE', 'status': 'a'},
    {'_id': 3, 'category': 'cafe', 'status': 'a'},
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var (res, _) = await collection.findOneAndUpdate(
       where.eq('category', 'cafe').eq('status', 'a'),
     
       ModifierBuilder().set('status', 'updated'),
   sort: <String, dynamic>{'category': 1},    findOneAndUpdateOptions:
          FindOneAndUpdateOptions(collation: CollationOptions('fr', strength: 1)));

  print('Updated document: ${res.lastErrorObject?.updatedExisting}'); // true

  print('Modified element original category: '
      '${res.value?['category']}'); // 'café';

  await cleanupDatabase();
}
