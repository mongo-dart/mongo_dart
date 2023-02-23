import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/base/update_union.dart';
import 'package:mongo_dart/src/utils/hint_union.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';

import '../../command/command.dart';
import '../../session/client_session.dart';
import '../../utils/map_keys.dart';
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
  Future<ReplaceOneDocumentRec> replaceOne(filter, update,
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
  Future<UpdateManyDocumentRec> updateMany(selector, update,
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

  @override
  Future<DeleteOneDocumentRec> deleteOne(selector,
      {WriteConcern? writeConcern,
      CollationOptions? collation,
      HintUnion? hint}) async {
    var deleteOperation = DeleteOneOperation(
        this,
        DeleteOneStatement(QueryUnion(selector),
            collation: collation, hint: hint),
        deleteOneOptions: DeleteOneOptions(writeConcern: writeConcern));
    return deleteOperation.executeDocument();
  }

  @override
  Future<DeleteManyDocumentRec> deleteMany(selector,
      {WriteConcern? writeConcern,
      CollationOptions? collation,
      HintUnion? hint}) async {
    var deleteOperation = DeleteManyOperation(
        this,
        DeleteManyStatement(QueryUnion(selector),
            collation: collation, hint: hint),
        deleteManyOptions: DeleteManyOptions(writeConcern: writeConcern));
    return deleteOperation.executeDocument();
  }

  @override
  Future<FindAndModifyDocumentRec> findAndModify(
      {query,
      sort,
      bool? remove,
      update,
      bool? returnNew,
      ProjectionDocument? fields,
      bool? upsert,
      List<ArrayFilter>? arrayFilters,
      HintUnion? hint,
      FindAndModifyOptions? findAndModifyOptions,
      Options? rawOptions}) async {
    IndexDocument? sortMap;
    if (sort is IndexDocument) {
      sortMap = sort;
    } else if (sort is Map) {
      sortMap = <String, Object>{...sort};
    } else if (sort is SelectorBuilder && sort.map[keyOrderby] != null) {
      sortMap = <String, Object>{...sort.map[keyOrderby]};
    } else if (query is SelectorBuilder && query.map[keyOrderby] != null) {
      sortMap = <String, Object>{...query.map[keyOrderby]};
    }

    var famOperation = FindAndModifyOperation(this,
        query: QueryUnion(query),
        sort: sortMap,
        remove: remove,
        update: UpdateUnion(update),
        returnNew: returnNew,
        fields: fields,
        upsert: upsert,
        arrayFilters: arrayFilters,
        hint: hint,
        findAndModifyOptions: findAndModifyOptions,
        rawOptions: rawOptions);
    return famOperation.executeDocument();
  }
}
