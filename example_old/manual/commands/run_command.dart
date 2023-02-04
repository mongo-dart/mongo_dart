import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/command/diagnostic_commands/ping_command/ping_command.dart';
import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var client = MongoClient(defaultUri);
  await client.connect();
  var db = client.db();
  await db.drop();

  Future cleanupDatabase() async {
    await client.close();
  }

  var ret = await db.runCommand({'ping': 1});
  print(ret); // {ok: 1.0};

  ret = await CommandOperation(db, {'ping': 1}, <String, Object>{}).process();
  print(ret); // {ok: 1.0};

  ret = await PingCommand(db.mongoClient).process();
  print(ret); // {ok: 1.0};

  ret = await db.pingCommand();
  print(ret); // {ok: 1.0};

  var result = await db.collection(r'$cmd').findOne({'ping': 1});
  print(result); // {ok: 1.0};

  try {
    await db.collection(r'$cmd').modernFind(filter: {'ping': 1}).toList();
  } catch (error) {
    print(
        error); // "MongoDart Error: Invalid collection name specified 'mongo-dart-example.$cmd'";
  }

  await cleanupDatabase();
}
