import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/database/base/mongo_collection.dart';

/// For op_msg
Future<BulkWriteResult> insertOrders(MongoCollection collection) async {
  var toInsert = <Map<String, dynamic>>[
    {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
    {'cust_num': 12911, 'item': 'book1', 'status': 'A'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
    {'cust_num': 81237, 'item': 'sample', 'status': 'A'},
    {'cust_num': 99999, 'item': 'book1', 'status': 'D'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 12911, 'item': 'sample', 'status': 'A'},
    {'cust_num': 12345, 'item': 'book1', 'status': 'A'},
    {'cust_num': 81237, 'item': 'abc123', 'status': 'A'},
    {'cust_num': 12911, 'item': 'sample', 'status': 'D'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
    {'cust_num': 12911, 'item': 'book1', 'status': 'R'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 99999, 'item': 'tst24', 'status': 'S'},
    {'cust_num': 99999, 'item': 'abc123', 'status': 'D'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 12911, 'item': 'sample', 'status': 'D'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 81237, 'item': 'book1', 'status': 'A'},
    {'cust_num': 99999, 'item': 'abc123', 'status': 'D'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'R'},
    {'cust_num': 12911, 'item': 'book1', 'status': 'A'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
    {'cust_num': 81237, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 12911, 'item': 'book1', 'status': 'S'},
    {'cust_num': 12345, 'item': 'sample', 'status': 'D'},
    {'cust_num': 12911, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 12345, 'item': 'book1', 'status': 'D'},
    {'cust_num': 99999, 'item': 'tst24', 'status': 'A'},
    {'cust_num': 81237, 'item': 'abc123', 'status': 'D'},
    {'cust_num': 12911, 'item': 'book1', 'status': 'A'},
    {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
    {'cust_num': 12911, 'item': 'book1', 'status': 'A'},
    {'cust_num': 12345, 'item': 'sample', 'status': 'R'},
  ];
  var (bulkWriteResult, _, _, _) = await collection.insertMany(toInsert);
  return bulkWriteResult;
}

/// For op_msg
Future<BulkWriteResult> insertFrenchCafe(MongoCollection collection) async {
  var toInsert = <Map<String, dynamic>>[
    {'_id': 1, 'category': 'café', 'status': 'A'},
    {'_id': 2, 'category': 'cafe', 'status': 'a'},
    {'_id': 3, 'category': 'cafE', 'status': 'a'}
  ];

  var (bulkWriteResult, _, _, _) = await collection.insertMany(toInsert);
  return bulkWriteResult;
}

/// For op_msg
Future<BulkWriteResult> insertMembers(MongoCollection collection) async {
  var toInsert = <Map<String, dynamic>>[
    {
      '_id': 1,
      'member': 'abc123',
      'status': 'P',
      'points': 0,
      'misc1': null,
      'misc2': null
    },
    {
      '_id': 2,
      'member': 'xyz123',
      'status': 'A',
      'points': 60,
      'misc1': 'reminder: ping me at 100pts',
      'misc2': 'Some random comment'
    },
    {
      '_id': 3,
      'member': 'lmn123',
      'status': 'P',
      'points': 0,
      'misc1': null,
      'misc2': null
    },
    {
      '_id': 4,
      'member': 'pqr123',
      'status': 'D',
      'points': 20,
      'misc1': 'Deactivated',
      'misc2': null
    },
    {
      '_id': 5,
      'member': 'ijk123',
      'status': 'P',
      'points': 0,
      'misc1': null,
      'misc2': null
    },
    {
      '_id': 6,
      'member': 'cde123',
      'status': 'A',
      'points': 86,
      'misc1': 'reminder: ping me at 100pts',
      'misc2': 'Some random comment'
    }
  ];

  var (bulkWriteResult, _, _, _) = await collection.insertMany(toInsert);
  return bulkWriteResult;
}

Future<BulkWriteResult> insertPeople(MongoCollection collection) async {
  var toInsert = <Map<String, dynamic>>[
    {'_id': 1, 'name': 'Tom', 'state': 'active', 'rating': 100, 'score': 5},
    {'_id': 2, 'name': 'William', 'state': 'busy', 'rating': 80, 'score': 4},
    {'_id': 3, 'name': 'Liz', 'state': 'on hold', 'rating': 70, 'score': 8},
    {'_id': 4, 'name': 'George', 'state': 'active', 'rating': 95, 'score': 8},
    {'_id': 5, 'name': 'Jim', 'state': 'idle', 'rating': 40, 'score': 3},
    {'_id': 6, 'name': 'Laureen', 'state': 'busy', 'rating': 87, 'score': 8},
    {'_id': 7, 'name': 'John', 'state': 'idle', 'rating': 72, 'score': 7}
  ];

  var (bulkWriteResult, _, _, _) = await collection.insertMany(toInsert);
  return bulkWriteResult;
}

Future<BulkWriteResult> insertManyDocuments(
    MongoCollection collection, int numberOfRecords) async {
  var toInsert = <Map<String, dynamic>>[];
  for (var n = 0; n < numberOfRecords; n++) {
    toInsert.add({'a': n});
  }

  var (bulkWriteResult, _, _, _) = await collection.insertMany(toInsert);
  return bulkWriteResult;
}
