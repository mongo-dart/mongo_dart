import 'package:mongo_dart/src/unions/hint_union.dart';
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
import '../../unions/projection_union.dart';
import '../../unions/sort_union.dart';
import '../../utils/map_keys.dart';
import '../../unions/query_union.dart';
import '../database.dart';
import '../modern_cursor.dart';

/// Collection clss for Stavle Api V1 and release greater or equal to 6.0
class MongoCollectionV117 extends MongoCollection {
  MongoCollectionV117(super.db, super.collectionName) : super.protected();

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

  /// Returns one document that satisfies the specified query criteria on
  /// the collection or view. If multiple documents satisfy the query,
  /// this method returns the first document according to the sort order
  /// or the natural order of sort parameter is not specified.
  /// In capped collections, natural order is the same as insertion order.
  /// If no document satisfies the query, the method returns null.
  ///
  /// In MongoDb this method only allows the filter and the projection
  /// parameters.
  /// This version has more parameters, and it is essentially a wrapper
  /// araound the find method with a fixed limit set to 1 that returns
  /// a document instead of a stream.
  @override
  Future<Map<String, dynamic>?> findOne(dynamic filter,
      {dynamic projection,
      dynamic sort,
      int? skip,
      dynamic hint,
      FindOptions? findOptions,
      MongoDocument? rawOptions}) async {
    var uFilter = (filter is QueryUnion) ? filter : QueryUnion(filter);
    var uProjection = (projection is ProjectionUnion)
        ? projection
        : ProjectionUnion(projection);
    var uSort = (sort is SortUnion) ? sort : SortUnion(sort);
    var uHint = (hint is HintUnion) ? hint : HintUnion(hint);

    var operation = FindOperation(this, uFilter,
        sort: uSort,
        projection: uProjection,
        hint: uHint,
        skip: skip != null && skip > 0 ? skip : null,
        limit: 1,
        findOptions: findOptions,
        rawOptions: rawOptions);

    return ModernCursor(operation, db.server).nextObject();
  }

  /// Selects documents in a collection or view and returns a stream
  /// of the selected documents.  @override
  @override
  Stream<Map<String, dynamic>> find(dynamic filter,
      {dynamic projection,
      dynamic sort,
      int? skip,
      int? limit,
      dynamic hint,
      FindOptions? findOptions,
      MongoDocument? rawOptions}) {
    var uFilter = (filter is QueryUnion) ? filter : QueryUnion(filter);
    var uProjection = ProjectionUnion(projection);
    var uSort = SortUnion(sort);
    var uHint = HintUnion(hint);

    var operation = FindOperation(this, uFilter,
        sort: uSort,
        projection: uProjection,
        hint: uHint,
        limit: limit != null && limit > 0 ? limit : null,
        skip: skip != null && skip > 0 ? skip : null,
        findOptions: findOptions,
        rawOptions: rawOptions);

    return ModernCursor(operation, db.server).stream;
  }
}
