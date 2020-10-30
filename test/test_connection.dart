import 'package:mongo_dart/mongo_dart.dart';
import 'package:logging/logging.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

// This test must be run manually with mongoDb dowm,
// Then, while it is running, start mongo db.
// If ok, it should print the ('Is connected!') message
void main() async {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  var db = Db(DefaultUri);
  var count = 0;
  while (count < 10) {
    try {
      await db.open();
      print('Is connected!');
      await db.close();
      break;
    } catch (e) {
      count++;
      print(e);
      await Future.delayed(Duration(seconds: 2));
    }
  }
}
