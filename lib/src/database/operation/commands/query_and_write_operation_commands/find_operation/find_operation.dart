import 'package:mongo_dart/mongo_dart.dart' show DbCollection, MongoDartError;
import 'package:mongo_dart/src/database/operation/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'find_options.dart';
import '../../base/command_operation.dart';
import 'find_result.dart';

class FindOperation extends CommandOperation {
  FindOperation(DbCollection collection,
      {this.filter,
      this.sort,
      this.projection,
      this.hint,
      this.hintDocument,
      this.skip,
      this.limit,
      FindOptions findOptions,
      Map<String, Object> rawOptions})
      : super(collection.db,
            <String, Object>{...?findOptions?.options, ...?rawOptions},
            collection: collection, aspect: Aspect.readOperation) {
    if (skip != null && skip < 1) {
      throw MongoDartError('Skip parameter must be a positive integer');
    }
    skip ??= 0;
    if (limit != null && limit < 0) {
      throw MongoDartError('Limit parameter must be a non-negative integer');
    }
    limit ??= 0;
  }

  /// Optional. The query predicate. If unspecified, then all documents in the
  /// collection will match the predicate.
  Map<String, Object> filter;

  /// Optional. The sort specification for the ordering of the results.
  Map<String, Object> sort;

  /// Optional. The projection specification to determine which fields
  /// to include in the returned documents.
  /// *See Projection and Projection Operators.*
  /// find() operations on views do not support the following projection
  /// operators:
  /// * $
  /// * $elemMatch
  /// * $slice
  /// * $meta
  Map<String, Object> projection;

  /// Optional. Index specification. Specify either the index name
  /// as a string (hint field) or the index key pattern (hintDocument field).
  /// If specified, then the query system will only consider plans
  /// using the hinted index.
  /// **starting in MongoDB 4.2**, with the following exception,
  /// hint is required if the command includes the min and/or max fields;
  /// hint is not required with min and/or max if the filter is an
  /// equality condition on the _id field { _id: <value> }.
  String hint;
  Map<String, Object> hintDocument;

  /// Positive integer 	- Optional.
  /// Number of documents to skip. Defaults to 0.
  int skip;

  /// Non-negative integer 	Optional.
  /// The maximum number of documents to return. If unspecified,
  /// then defaults to no limit.
  /// A limit of 0 is equivalent to setting no limit.
  int limit;

  /// Returns a tailable cursor for a capped collections.
  bool get isTailable => options[keyTailable] ?? false;

  bool get isAwaitData => options[keyAwaitData] ?? false;

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyFind: collection.collectionName,
      if (filter != null) keyFilter: filter,
      if (sort != null) keySort: sort,
      if (projection != null) keyProjection: projection,
      if (hint != null)
        keyHint: hint
      else if (hintDocument != null)
        keyHint: hintDocument,
      if (skip != null && skip > 0) keySkip: skip,
      if (limit != null && limit > 0) keyLimit: limit,
      //if (findOptions != null) ...findOptions.options
    };
  }

  Future<FindResult> executeDocument() async {
    var result = await super.execute();
    return FindResult(result);
  }
}
