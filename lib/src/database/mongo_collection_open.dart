import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/insert_one/open/insert_one_operation_open.dart';

import '../command/command.dart';
import '../command/query_and_write_operation_commands/wrapper/insert_many/open/insert_many_operation_open.dart';
import 'database.dart';

class MongoCollectionOpen extends MongoCollection {
  MongoCollectionOpen(super.db, super.collectionName) : super.protected();

  // Insert one document into this collection
  // Returns a WriteResult object
  @override
  Future<WriteResult> insertOne(MongoDocument document,
          {InsertOneOptions? insertOneOptions}) async =>
      InsertOneOperationOpen(this, document,
              insertOneOptions: insertOneOptions?.toOneOpen)
          .executeDocument();

  /// Insert many document into this collection
  /// Returns a BulkWriteResult object
  @override
  Future<BulkWriteResult> insertMany(List<MongoDocument> documents,
          {InsertManyOptions? insertManyOptions}) async =>
      InsertManyOperationOpen(this, documents,
              insertManyOptions: insertManyOptions?.toManyOpen)
          .executeDocument();
}
