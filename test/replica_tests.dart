library replica_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
//import 'package:logging/logging.dart';
import 'package:test/test.dart';

const DefaultUri1 = 'mongodb://127.0.0.1:27001';
const DefaultUri2 = 'mongodb://127.0.0.1:27002';
const DefaultUri3 = 'mongodb://127.0.0.1:27003';

Future testCollectionInfoCursor() {
  Db db = new Db.pool([
    "${DefaultUri1}/mongo_dart-test",
    "${DefaultUri2}/mongo_dart-test",
    "${DefaultUri3}/mongo_dart-test"
  ], 'testCollectionInfoCursor');
  DbCollection newColl;
  return db.open(writeConcern: WriteConcern.JOURNALED).then((c) {
    newColl = db.collection("new_collecion");
    return newColl.remove({});
  }).then((v) {
    return newColl.insertAll([
      {"a": 1}
    ]);
  }).then((v) {
    return db.getCollectionInfos({'name': 'new_collecion'});
  }).then((v) {
    expect(v, hasLength(1));
    return db.close();
  });
}

main() {
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
