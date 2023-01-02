import '../../command/command.dart';
import '../database.dart';

/// Collection clss for Stavle Api V1 and release greater or equal to 6.0
class MongoCollectionV117 extends MongoCollection {
  MongoCollectionV117(super.db, super.collectionName) : super.protected();

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
