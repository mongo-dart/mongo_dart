import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../core/error/mongo_dart_error.dart';
import '../../../database/base/mongo_collection.dart';
import '../../../session/client_session.dart';
import 'find_options.dart';
import '../../base/command_operation.dart';
import 'find_result.dart';

class FindOperation extends CommandOperation {
  FindOperation(MongoCollection collection,
      {this.filter,
      this.sort,
      this.projection,
      this.hint,
      this.hintDocument,
      this.skip,
      this.limit,
      super.session,
      FindOptions? findOptions,
      Map<String, Object>? rawOptions})
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

  /// Optional. The query predicate. If unspecified, then all documents in the
  /// collection will match the predicate.
  Map<String, dynamic>? filter;

  /// Optional. The sort specification for the ordering of the results.
  Map<String, Object>? sort;

  /// Optional. The projection specification to determine which fields
  /// to include in the returned documents.
  /// *See Projection and Projection Operators.*
  /// find() operations on views do not support the following projection
  /// operators:
  /// * $
  /// * $elemMatch
  /// * $slice
  /// * $meta
  Map<String, Object>? projection;

  /// Optional. Index specification. Specify either the index name
  /// as a string (hint field) or the index key pattern (hintDocument field).
  /// If specified, then the query system will only consider plans
  /// using the hinted index.
  /// **starting in MongoDB 4.2**, with the following exception,
  /// hint is required if the command includes the min and/or max fields;
  /// hint is not required with min and/or max if the filter is an
  /// equality condition on the _id field { _id: <value> }.
  String? hint;
  Map<String, Object>? hintDocument;

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
        filter != null &&
        limit != null &&
        limit! == 1) {
      return <String, dynamic>{
        for (var key in filter!.keys) key: filter![key] ?? ''
      };
    }
    return <String, dynamic>{
      keyFind: collection!.collectionName,
      if (filter != null) keyFilter: filter!,
      if (sort != null) keySort: sort!,
      if (projection != null) keyProjection: projection!,
      if (hint != null)
        keyHint: hint!
      else if (hintDocument != null)
        keyHint: hintDocument!,
      if (skip != null && skip! > 0) keySkip: skip!,
      if (limit != null && limit! > 0) keyLimit: limit!,
    };
  }

  Future<FindResult> executeDocument({ClientSession? session}) async {
    if (collection!.collectionName == r'$cmd') {
      throw MongoDartError('cannot return a FindResult object '
          r'for a coomand request ($cmd collection)');
    }
    return FindResult(await process());
  }
}
