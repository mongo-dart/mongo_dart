import 'package:logging/logging.dart'
    show Level, LogRecord, Logger, hierarchicalLoggingEnabled;
import 'package:mongo_dart/src/mongo_client.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  hierarchicalLoggingEnabled = true;
  //Logger.root.level = Level.OFF;
  Logger('Mongoconnection example').level = Level.INFO;

  void listener(LogRecord r) {
    var name = r.loggerName;
    print('${r.time}: $name: ${r.message}');
  }

  Logger.root.onRecord.listen(listener);

  var client = MongoClient(defaultUri);
  await client.connect();
  //var db = client.db();

  Future cleanupDatabase() async {
    await client.close();
  }

  await cleanupDatabase();
}
