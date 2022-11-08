library replica_tests;

import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/write_concern.dart';
import 'dart:async';
//import 'package:logging/logging.dart';
import 'package:test/test.dart';

const defaultUri1 = 'mongodb://127.0.0.1:27001';
const defaultUri2 = 'mongodb://127.0.0.1:27002';
const defaultUri3 = 'mongodb://127.0.0.1:27003';

Future testCollectionInfoCursor() async {
  var db = Db.pool([
    '$defaultUri1/mongo_dart-test',
    '$defaultUri2/mongo_dart-test',
    '$defaultUri3/mongo_dart-test'
  ], 'testCollectionInfoCursor');
  DbCollection newColl;
  await db.open(writeConcern: WriteConcern.journaled);

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
