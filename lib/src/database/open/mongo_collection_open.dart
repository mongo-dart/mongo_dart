import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/base/update_union.dart';
import 'package:mongo_dart/src/utils/hint_union.dart';

import '../../command/command.dart';
import '../../session/client_session.dart';
import '../../utils/query_union.dart';
import '../database.dart';

class MongoCollectionOpen extends MongoCollection {
  MongoCollectionOpen(super.db, super.collectionName) : super.protected();

  // Insert one document into this collection
  // Returns a WriteResult object
  @override
  Future<InsertOneDocumentRec> insertOne(MongoDocument document,
          {ClientSession? session, InsertOneOptions? insertOneOptions}) async =>
      InsertOneOperationOpen(this, document,
              session: session, insertOneOptions: insertOneOptions?.toOneOpen)
          .executeDocument();

  /// Insert many document into this collection
  /// Returns a BulkWriteResult object
  @override
  Future<InsertManyDocumentRec> insertMany(List<MongoDocument> documents,
          {ClientSession? session,
          InsertManyOptions? insertManyOptions}) async =>
      InsertManyOperationOpen(this, documents,
              session: session,
              insertManyOptions: insertManyOptions?.toManyOpen)
          .executeDocument();

  // Update one document into this collection
  @override
  Future<UpdateOneDocumentRec> updateOne(filter, update,
      {bool? upsert,
      WriteConcern? writeConcern,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      HintUnion? hint}) async {
    var updateOneOperation = UpdateOneOperation(
        this,
        UpdateOneStatement(QueryUnion(filter), UpdateUnion(update),
            upsert: upsert,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint),
        updateOneOptions: UpdateOneOptions(writeConcern: writeConcern));
    return updateOneOperation.executeDocument();
  }

  @override
  Future<WriteResult> replaceOne(filter, update,
      {bool? upsert,
      WriteConcern? writeConcern,
      CollationOptions? collation,
      HintUnion? hint}) async {
    var replaceOneOperation = ReplaceOneOperation(
        this,
        ReplaceOneStatement(QueryUnion(filter), UpdateUnion(update),
            upsert: upsert, collation: collation, hint: hint),
        replaceOneOptions: ReplaceOneOptions(writeConcern: writeConcern));
    return replaceOneOperation.executeDocument();
  }

  @override
  Future<WriteResult> updateMany(selector, update,
      {bool? upsert,
      WriteConcern? writeConcern,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      HintUnion? hint}) async {
    var updateManyOperation = UpdateManyOperation(
        this,
        UpdateManyStatement(QueryUnion(selector), UpdateUnion(update),
            upsert: upsert,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint),
        updateManyOptions: UpdateManyOptions(writeConcern: writeConcern));
    return updateManyOperation.executeDocument();
  }
}
