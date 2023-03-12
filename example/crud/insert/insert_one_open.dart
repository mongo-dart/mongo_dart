import 'package:logging/logging.dart'
    show Level, LogRecord, Logger, hierarchicalLoggingEnabled;
import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = 'localhost';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  hierarchicalLoggingEnabled = true;
  Logger('Mongoconnection example').level = Level.INFO;

  void listener(LogRecord r) {
    var name = r.loggerName;
    print('${r.time}: $name: ${r.message}');
  }

  Logger.root.onRecord.listen(listener);

  var client = MongoClient(defaultUri);
  await client.connect();
  var db = client.db();

  Future cleanupDatabase() async {
    await client.close();
  }

  var collectionName = 'insert-one';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var (ret, _, _, _) = await collection.insertOne(<String, dynamic>{
    '_id': 1,
    'name': 'Tom',
    'state': 'active',
    'rating': 100,
    'score': 5
  });

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.findOne();

  print('Fetched: "${res?['name']}"');
  // Tom

  await cleanupDatabase();
}
