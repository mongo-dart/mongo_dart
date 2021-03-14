import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final db = Db('mongodb://127.0.0.1/testdb');

  await db.open();

  var collection = db.collection('unorderedBulkHelper');
  // clean data if the example is run more than once.
  await collection.drop();

  /// Bulk write returns an instance of `BulkWriteResult` class
  /// that is a convenient way of reading the result data.
  /// If you prefer the server response, a serverResponses list of
  /// document is available in the `BulkWriteResult` object.
  var ret = await collection.bulkWrite([
    {
      /// Insert many is specific to the mongo_dart driver.
      /// The mongo shell does not have this method
      /// It is similar to the `insertMany` method, with the difference
      /// that here we have no limit of document numbers, while the `insertMany`
      /// is limited depending on the MongoDb version (recent releases
      /// set this limit to 100,000 documents).
      ///
      /// You can use the convenient constant (here bulkInsertMany)
      /// or a simple string ('insertMany').
      bulkInsertMany: {
        bulkDocuments: [
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
        ]
      }
    },
    {
      /// here also you can use the convenient constants or the string
      /// like in Mongo shell
      bulkUpdateMany: {
        bulkFilter: {'status': 'D'},
        bulkUpdate: {
          r'$set': {'status': 'd'}
        }
      }
    },
    {
      bulkUpdateOne: {
        bulkFilter: {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
        bulkUpdate: {
          r'$inc': {'ordered': 1}
        }
      }
    },
    {
      bulkReplaceOne: {
        bulkFilter: {'cust_num': 12345, 'item': 'tst24', 'status': 'D'},
        bulkReplacement: {
          'cust_num': 12345,
          'item': 'tst24',
          'status': 'Replaced'
        },
        bulkUpsert: true
      }
    }

    /// Unordered operations will be executed in an "optimized" way.
    /// Today the driver joins all inserts and execute them and then
    /// does the same with updates and deletes.
    /// Please, note that this is the actual implementation.
    /// Do not rely on this logic as it could change in the future.
    /// 
    /// Any error will not stop the execution of other operations.
  ], ordered: false);

  print(ret.ok); // 1.0
  print(ret.operationSucceeded); // true
  print(ret.hasWriteErrors); // false
  print(ret.hasWriteConcernError); // false
  print(ret.nInserted); // 35
  print(ret.nUpserted); // 1
  print(ret.nModified); // 14
  print(ret.nMatched); // 15
  print(ret.nRemoved); // 0
  print(ret.isSuccess); // true

  await db.close();
}
