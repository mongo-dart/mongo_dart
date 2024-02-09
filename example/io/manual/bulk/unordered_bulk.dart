import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final db = Db('mongodb://127.0.0.1/testdb');

  await db.open();

  var collection = db.collection('unorderedBulk');
  // clean data if the example is run more than once.
  await collection.drop();

  /// Here we create the bulk object. UnorderedBulk will execute
  /// all the operations without any guarantee of the order in which they
  /// are processed.
  var bulk = UnorderedBulk(collection, writeConcern: WriteConcern(w: 1));

  /// Bulk has the following methods for inserting operations:
  /// - insertOne
  /// - insertMany
  /// - updateOne | updateOneFromMap
  /// - updateMany | updateManyFromMap
  /// - replaceOne | replaceOneFormMap
  /// - deleteOne | deleteOneFromMap
  /// - deleteMany | deleteManyFromMap
  bulk.insertMany([
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
  ]);

  ///
  /// Alternatively the following could have been written in a shell like way:
  /// '''dart
  ///bulk.updateManyFromMap({
  ///  bulkUpdateMany: {
  ///    bulkFilter: {'status': 'D'},
  ///    bulkUpdate: {
  ///      r'$set': {'status': 'd'}
  ///    }
  ///  }
  ///});
  ///'''
  bulk.updateMany(UpdateManyStatement(where.eq('status', 'D').map[key$Query],
      ModifierBuilder().set('status', 'd').map));

  bulk.updateOne(UpdateOneStatement(
      {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
      ModifierBuilder().inc('ordered', 1).map));

  bulk.replaceOne(ReplaceOneStatement({
    'cust_num': 12345,
    'item': 'tst24',
    'status': 'D'
  }, {
    'cust_num': 12345,
    'item': 'tst24',
    'status': 'Replaced'
  }, upsert: true));

  /// Bulk `executeDocument()` returns an instance of the `BulkWriteResult`
  /// class that is a convenient way of reading the result data.
  /// If you prefer the server response, a serverResponses list of
  /// document is available in the `BulkWriteResult` object.
  /// or you can run the executeBulk() method that directly returns the server
  /// response
  var ret = await bulk.executeDocument();

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
