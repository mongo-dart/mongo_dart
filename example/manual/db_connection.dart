import 'package:mongo_dart/mongo_dart.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

void main() async {
  var db = await connection.db;

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'delete-many';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany([
    {'_id': 3, 'name': 'John', 'age': 32},
    {'_id': 4, 'name': 'Mira', 'age': 27},
    {'_id': 7, 'name': 'Luis', 'age': 42},
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.deleteMany(where.lt('age', 40));

  print('Removed documents: ${res.nRemoved}'); // 2

  var findResult = await collection.find().toList();

  print('First record name: ${findResult.first['name']}'); // 'Luis';

  await connection.close();
}

DbConnection connection = DbConnection._(dbAddress, '27017', dbName);

class DbConnection {
  DbConnection._(this.host, this.port, this.dbName);
  final String host;
  final String port;
  final String dbName;

  String get connectionString => 'mongodb://$host:$port/$dbName';

  int retryAttempts = 5;

  static bool started = false;

  Db? _db;
  Future<Db> get db async => getConnection();

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
    }
  }

  Future<Db> getConnection() async {
    if (_db == null || !_db!.isConnected) {
      await close();
      var retry = 0;
      while (true) {
        try {
          retry++;
          var db = Db(connectionString);
          await db.open();
          _db = db;
          print('OK after "$retry" attempts');
          break;
        } catch (e) {
          if (retryAttempts < retry) {
            print('Exiting after "$retry" attempts');
            rethrow;
          }
          // each time waits a little bit more before re-trying
          await Future.delayed(Duration(milliseconds: 100 * retry));
        }
      }
    }
    return _db!;
  }
}
