// Example Tested on release 0.7.0
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/database/modern_cursor.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/utils/query_union.dart';

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

  var collectionName = 'cursor';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var documents = <Map<String, dynamic>>[
    for (var idx = 0; idx < 1000; idx++) {'key': idx}
  ];

  var (ret, _, _, _) = await collection.insertMany(documents);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  /// The batch size refers to the number of records that are fetched
  /// togheter from the server.
  /// The cursor class store the records fetched and returns one by one
  /// when calling the nextObject() method.
  ///
  /// The system differentiate between two different kinds of "fetch":
  /// - the first batch
  /// - all the other batches
  ///
  /// You can set the size of the first batch setting the operation
  /// option (in this example "100"). The default is 101.
  /// For all subsequent fetches the cursor batch size will be used,
  /// You can (if needed) set it as a parameter when creating the cursor
  /// (here 150) or changing it later, setting the cursor.batchSize
  /// variable (here 200).
  ///
  /// By default the cursor batch size is set equal to the operation one.
  /// In our example, without setting 150 and then 200 it would heve been 100).
  /// Please note. This behavior differs from the mongodb shell,
  /// where the first bach has a size of 101 and the following
  /// read (if not set otherwise) has a <no-limit> size, i.e. reads all other
  /// records in one batch.
  ///
  /// The batch size must be a positive integer.
  /// The exception is setting zero in the operation
  /// In this case the meaning is:
  /// "Simply prepare the cursor for further reading".
  /// This can be useful if you use the low level operation `execute()`
  /// and the susequent `getMore` command, otherwise it is transparent in
  /// the nextObject() call.
  var cursor = ModernCursor(
      FindOperation(
          collection,
          QueryUnion({
            'key': {r'$gte': 0}
          }),
          findOptions: FindOptions(batchSize: 100)),
      db.server,
      batchSize: 150);

  var sum = 0;
  // Just an example, normally it is not needed.
  cursor.batchSize = 200;

  while (true) {
    var doc = await cursor.nextObject();
    if (doc == null) {
      await cursor.close();
      break;
    }

    // do something with "doc"
    var idx = doc['key'] as int? ?? 0;
    if (idx > 10) {
      continue;
    }
    sum += idx;
  }

  print('The sum of the first 10 records is $sum'); // 55;

  await cleanupDatabase();
}
