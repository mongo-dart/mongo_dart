import 'package:logging/logging.dart'
    show Level, LogRecord, Logger, hierarchicalLoggingEnabled;
import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  hierarchicalLoggingEnabled = true;
  //Logger.root.level = Level.OFF;
  Logger('Mongoconnection example').level = Level.FINE;

  void listener(LogRecord r) {
    var name = r.loggerName;
    print('${r.time}: $name: ${r.message}');
  }

  Logger.root.onRecord.listen(listener);

  var client = MongoClient(defaultUri);
  await client.connect();
  client.topology?.servers.first.refreshStatus();
  client.topology?.servers.first.refreshStatus();
  client.topology?.servers.first.refreshStatus();
  await client.topology?.servers.first.refreshStatus();
  await Future.delayed(Duration(seconds: 2));
  print(client.topology?.servers.first.connectionPool.connectionsNumber);

  //var db = client.db();

  Future cleanupDatabase() async {
    await client.close();
  }

  await cleanupDatabase();
}
