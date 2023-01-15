import 'package:logging/logging.dart'
    show Level, LogRecord, Logger, hierarchicalLoggingEnabled;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';

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

  var client = MongoClient(defaultUri,
      mongoClientOptions: MongoClientOptions()
        ..serverApi = ServerApi(ServerApiVersion.v1));
  await client.connect();
  var db = client.db();

  Future cleanupDatabase() async {
    await client.close();
  }

  var collectionName = 'insert-one';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  // *** Simple case ***
  var ret = await collection.insertOne(<String, dynamic>{
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

// *** In Session ***
  var session = client.startSession();
  ret = await collection.insertOne(<String, dynamic>{
    '_id': 2,
    'name': 'Ezra',
    'state': 'active',
    'rating': 90,
    'score': 6
  }, session: session);

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  await session.endSession();

  res = await collection.findOne(where.eq('rating', 90));

  print('Fetched: "${res?['name']}"');
  // Ezra

// *** In Transaction committed ***
  session = client.startSession();
  session.startTransaction();
  ret = await collection.insertOne(<String, dynamic>{
    '_id': 3,
    'name': 'Nathan',
    'state': 'active',
    'rating': 98,
    'score': 4
  }, session: session);

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  var commitRes = await session.commitTransaction();
  if (commitRes?[keyOk] == 0.0) {
    print('${commitRes?[keyErrmsg]}');
  }
  await session.endSession();

  res = await collection.findOne(where.sortBy('score'));

  print('Fetched: "${res?['name']}"');
  // Nathan

// *** In Transaction aborted ***
  session = client.startSession();
  session.startTransaction();
  ret = await collection.insertOne(<String, dynamic>{
    '_id': 4,
    'name': 'Anne',
    'state': 'inactive',
    'rating': 120,
  }, session: session);

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  await session.endSession();

  res = await collection.findOne(where.sortBy('name'));

  print('Fetched: "${res?['name']}"');
  // Ezra

  await cleanupDatabase();
}
