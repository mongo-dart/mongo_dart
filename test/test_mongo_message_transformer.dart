library database_tests;
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:logging/logging.dart';
Logger _log = new Logger('Tester');
int counter = 0;
processMessage(MongoReplyMessage message) {
  print('Got ${counter++} message $message');
}
main() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
//  new Logger('Db').level = Level.ALL;
  var listener = (LogRecord r) {
    var name = r.loggerName;
    if (name.length > 15) {
      name = name.substring(0, 15);
    }
    while (name.length < 15) {
      name = "$name ";
    }
    ("${r.time}: $name: ${r.message}");
  };
  Logger.root.onRecord.listen(listener);
  var messageTransformer = new MongoMessageTransformer();
  var inputStream = new File(r'c:\projects\mongo_dart\test\debug_data.bin').openRead()
    .transform(new ChunkTransformer(11))
    .transform(messageTransformer);

  inputStream.listen( processMessage,
  onDone: () => print('Finished'));
}