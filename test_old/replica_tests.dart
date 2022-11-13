library replica_tests;

import 'package:mongo_dart/src/core/auth/scram_sha256_authenticator.dart';
import 'package:mongo_dart/src/database/dbcollection.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'dart:async';
import 'package:test/test.dart';

const defaultUri1 = 'mongodb://127.0.0.1:27001';
const defaultUri2 = 'mongodb://127.0.0.1:27002';
const defaultUri3 = 'mongodb://127.0.0.1:27003';

Future testCollectionInfoCursor() async {
  DbCollection newColl;

  var client = MongoClient(
      'mongodb://$defaultUri1,$defaultUri2,$defaultUri3/mongo_dart-test'
      '?authMechanism=${ScramSha256Authenticator.name}');
  await client.connect();
  final db = client.db();

  newColl = db.collection('new_collecion');
  await newColl.remove({});

  await newColl.insertAll([
    {'a': 1}
  ]);

  var v = await db.getCollectionInfos({'name': 'new_collecion'});

  expect(v, hasLength(1));
  await client.close();
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
