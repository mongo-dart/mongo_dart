import 'package:mongo_dart/src/utils/hint_union.dart';
import 'package:mongo_dart/src/utils/query_union.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';

import '../../command/base/operation_base.dart';
import '../../command/command.dart';
import '../../command/query_and_write_operation_commands/update_operation/base/update_union.dart';
import '../../command/query_and_write_operation_commands/wrapper/find_one_and_delete/base/find_one_and_delete_operation.dart';
import '../../command/query_and_write_operation_commands/wrapper/find_one_and_delete/base/find_one_and_delete_options.dart';
import '../../command/query_and_write_operation_commands/wrapper/find_one_and_replace/base/find_one_and_replace_operation.dart';
import '../../command/query_and_write_operation_commands/wrapper/find_one_and_replace/base/find_one_and_replace_options.dart';
import '../../command/query_and_write_operation_commands/wrapper/find_one_and_update/base/find_one_and_update_operation.dart';
import '../../command/query_and_write_operation_commands/wrapper/find_one_and_update/base/find_one_and_update_options.dart';
import '../../session/client_session.dart';
import '../../utils/map_keys.dart';
import '../database.dart';

class MongoCollectionV1 extends MongoCollection {
  MongoCollectionV1(super.db, super.collectionName) : super.protected();

  // Insert one document into this collection
  // Returns a WriteResult object
  @override
  Future<InsertOneDocumentRec> insertOne(MongoDocument document,
          {ClientSession? session, InsertOneOptions? insertOneOptions}) async =>
      InsertOneOperationV1(this, document,
              session: session, insertOneOptions: insertOneOptions?.toOneV1)
          .executeDocument();

  /// Insert many document into this collection
  /// Returns a BulkWriteResult object
  @override
  Future<InsertManyDocumentRec> insertMany(List<MongoDocument> documents,
          {ClientSession? session,
          InsertManyOptions? insertManyOptions}) async =>
      InsertManyOperationV1(this, documents,
              session: session, insertManyOptions: insertManyOptions?.toManyV1)
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
  Future<FindOneAndDeleteDocumentRec> findOneAndDelete(query,
      {ProjectionDocument? fields,
      sort,
      ClientSession? session,
      HintUnion? hint,
      FindOneAndDeleteOptions? findOneAndDeleteOptions,
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

    var famOperation = FindOneAndDeleteOperation(this, QueryUnion(query),
        fields: fields,
        sort: sortMap,
        hint: hint,
        findOneAndDeleteOptions: findOneAndDeleteOptions,
        rawOptions: rawOptions);
    return famOperation.executeDocument();
  }

  @override
  Future<FindOneAndReplaceDocumentRec> findOneAndReplace(
      query, MongoDocument replacement,
      {ProjectionDocument? fields,
      sort,
      bool? upsert,
      bool? returnNew,
      ClientSession? session,
      HintUnion? hint,
      FindOneAndReplaceOptions? findOneAndReplaceOptions,
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

    var famOperation = FindOneAndReplaceOperation(
        this, QueryUnion(query), replacement,
        fields: fields,
        sort: sortMap,
        returnNew: returnNew,
        upsert: upsert,
        session: session,
        hint: hint,
        findOneAndReplaceOptions: findOneAndReplaceOptions,
        rawOptions: rawOptions);
    return famOperation.executeDocument();
  }

  @override
  Future<FindOneAndUpdateDocumentRec> findOneAndUpdate(query, update,
      {ProjectionDocument? fields,
      sort,
      bool? upsert,
      bool? returnNew,
      List<ArrayFilter>? arrayFilters,
      ClientSession? session,
      HintUnion? hint,
      FindOneAndUpdateOptions? findOneAndUpdateOptions,
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

    var famOperation = FindOneAndUpdateOperation(this,
        query: QueryUnion(query),
        update: UpdateUnion(update),
        fields: fields,
        sort: sortMap,
        upsert: upsert,
        returnNew: returnNew,
        arrayFilters: arrayFilters,
        session: session,
        hint: hint,
        findOneAndUpdateOptions: findOneAndUpdateOptions,
        rawOptions: rawOptions);
    return famOperation.executeDocument();
  }
}
