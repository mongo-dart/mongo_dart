library replica_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
//import 'package:logging/logging.dart';
import 'package:test/test.dart';

const DefaultUri1 = 'mongodb://127.0.0.1:27001';
const DefaultUri2 = 'mongodb://127.0.0.1:27002';
const DefaultUri3 = 'mongodb://127.0.0.1:27003';

Future testCollectionInfoCursor() async {
  var db = Db.pool([
    '$DefaultUri1/mongo_dart-test',
    '$DefaultUri2/mongo_dart-test',
    '$DefaultUri3/mongo_dart-test'
  ], 'testCollectionInfoCursor');
  DbCollection newColl;
  await db.open(writeConcern: WriteConcern.JOURNALED);

  newColl = db.collection('new_collecion');
  await newColl.remove({});

  await newColl.insertAll([
    {'a': 1}
  ]);

  var v = await db.getCollectionInfos({'name': 'new_collecion'});

  expect(v, hasLength(1));
  await db.close();
}

void main() {
//  hierarchicalLoggingEnabled = true;
//  Logger.root.level = Level.OFF;
//  new Logger('ConnectionManager').level = Level.ALL;
//  var listener = (LogRecord r) {
//    var name = r.loggerName;
//    if (name.length > 15) {
//      name = name.substring(0, 15);
//    }
//    while (name.length < 15) {
//      name = "$name ";
//    }
//    print("${r.time}: $name: ${r.message}");
//  };
//  Logger.root.onRecord.listen(listener);

  group('DbCollection tests:', () {
    test('testCollectionInfoCursor', testCollectionInfoCursor);
  });
}
