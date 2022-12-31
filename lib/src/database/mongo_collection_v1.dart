import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/insert_many/v1/insert_many_operation_v1.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/insert_one/v1/insert_one_operation_v1.dart';

import '../command/command.dart';
import 'database.dart';

class MongoCollectionV1 extends MongoCollection {
  MongoCollectionV1(super.db, super.collectionName) : super.protected();

  // Insert one document into this collection
  // Returns a WriteResult object
  @override
  Future<WriteResult> insertOne(MongoDocument document,
          {InsertOneOptions? insertOneOptions}) async =>
      InsertOneOperationV1(this, document,
              insertOneOptions: insertOneOptions?.toOneV1)
          .executeDocument();

  /// Insert many document into this collection
  /// Returns a BulkWriteResult object
  @override
  Future<BulkWriteResult> insertMany(List<MongoDocument> documents,
          {InsertManyOptions? insertManyOptions}) async =>
      InsertManyOperationV1(this, documents,
              insertManyOptions: insertManyOptions?.toManyV1)
          .executeDocument();
}
