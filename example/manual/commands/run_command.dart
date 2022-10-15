import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/commands/diagnostic_commands/ping_command/ping_command.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var db = Db(defaultUri);
  await db.open();
  await db.drop();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var ret = await db.runCommand({'ping': 1});
  print(ret); // {ok: 1.0};

  ret = await CommandOperation(db, <String, Object>{}, command: {'ping': 1})
      .execute();
  print(ret); // {ok: 1.0};

  ret = await PingCommand(db).execute();
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
