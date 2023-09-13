import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/unions/projection_union.dart';
import 'package:mongo_dart/src/unions/sort_union.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../../core/error/mongo_dart_error.dart';
import '../../../../database/database.dart';
import '../../../../server_api_version.dart';
import '../../../../session/client_session.dart';
import '../../../../unions/hint_union.dart';
import '../../../../unions/query_union.dart';
import '../open/find_operation_open.dart';
import '../v1/find_operation_v1.dart';
import 'find_options.dart';
import '../../../base/command_operation.dart';
import '../find_result.dart';

typedef FindDocumentRec = (FindResult findResult, MongoDocument serverDocument);

base class FindOperation extends CommandOperation {
  FindOperation.protected(MongoCollection collection, this.filter,
      {this.sort,
      this.projection,
      this.hint,
      this.skip,
      this.limit,
      super.session,
      FindOptions? findOptions,
      Options? rawOptions})
      : super(collection.db, {},
            <String, dynamic>{...?findOptions?.options, ...?rawOptions},
            collection: collection, aspect: Aspect.readOperation) {
    if (skip != null && skip! < 1) {
      throw MongoDartError('Skip parameter must be a positive integer');
    }
    skip ??= 0;
    if (limit != null && limit! < 0) {
      throw MongoDartError('Limit parameter must be a non-negative integer');
    }
    limit ??= 0;
  }

  factory FindOperation(
    MongoCollection collection,
    QueryUnion filter, {
    SortUnion? sort,
    ProjectionUnion? projection,
    HintUnion? hint,
    int? skip,
    int? limit,
    ClientSession? session,
    FindOptions? findOptions,
    Options? rawOptions,
  }) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return FindOperationV1(collection, filter,
              sort: sort,
              projection: projection,
              hint: hint,
              skip: skip,
              limit: limit,
              session: session,
              findOptions: findOptions?.toV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return FindOperationOpen(collection, filter,
        sort: sort,
        projection: projection,
        hint: hint,
        skip: skip,
        limit: limit,
        session: session,
        findOptions: findOptions?.toOpen,
        rawOptions: rawOptions);
  }

  /// Optional. The query predicate. If unspecified, then all documents in the
  /// collection will match the predicate.
  QueryUnion filter;

  /// Optional. The sort specification for the ordering of the results.
  SortUnion? sort;

  /// Optional. The projection specification to determine which fields
  /// to include in the returned documents.
  /// *See Projection and Projection Operators.*
  /// find({}) operations on views do not support the following projection
  /// operators:
  /// * $
  /// * $elemMatch
  /// * $slice
  /// * $meta
  ProjectionUnion? projection;

  /// Optional. Index specification. Specify either the index name
  /// as a string or the index key pattern.
  /// If specified, then the query system will only consider plans
  /// using the hinted index.
  /// **starting in MongoDB 4.2**, with the following exception,
  /// hint is required if the command includes the min and/or max fields;
  /// hint is not required with min and/or max if the filter is an
  /// equality condition on the _id field { _id: <value> }.
  HintUnion? hint;

  /// Positive integer 	- Optional.
  /// Number of documents to skip. Defaults to 0.
  int? skip;

  /// Non-negative integer 	Optional.
  /// The maximum number of documents to return. If unspecified,
  /// then defaults to no limit.
  /// A limit of 0 is equivalent to setting no limit.
  int? limit;

  /// Returns a tailable cursor for a capped collections.
  bool get isTailable => options[keyTailable] as bool? ?? false;

  bool get isAwaitData => options[keyAwaitData] as bool? ?? false;

  @override
  Command $buildCommand() {
    if (collection!.collectionName == r'$cmd' &&
        !filter.isNull &&
        limit != null &&
        limit! == 1) {
      return <String, dynamic>{
        for (var key in filter.query.keys) key: filter.query[key] ?? ''
      };
    }
    return <String, dynamic>{
      keyFind: collection!.collectionName,
      if (!filter.isNull) keyFilter: filter.query,
      if (sort != null && !sort!.isNull) keySort: sort!.sort,
      if (projection != null && !projection!.isNull)
        keyProjection: projection!.projection,
      if (hint != null && !hint!.isNull) keyHint: hint!.value,
      if (skip != null && skip! > 0) keySkip: skip!,
      if (limit != null && limit! > 0) keyLimit: limit!,
    };
  }

  Future<FindDocumentRec> executeDocument({ClientSession? session}) async {
    if (collection!.collectionName == r'$cmd') {
      throw MongoDartError('cannot return a FindResult object '
          r'for a coomand request ($cmd collection)');
    }
    var ret = await execute();
    return (FindResult(ret), ret);
  }
}
