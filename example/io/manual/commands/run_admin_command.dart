import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/base/db_admin_command_operation.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var db = Db(defaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }
  var command = DbAdminCommandOperation(db, {'listDatabases': 1});
  var ret = await command.execute();
  print(ret);

  await cleanupDatabase();
}
