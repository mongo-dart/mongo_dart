import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'count_options.dart';
import '../../base/command_operation.dart';
import 'count_result.dart';

/// Collection is the collection on which the operation is performed
/// In case of admin/diagnostic pipeline which does not require an underlying
/// collection, the db parameter must be passed instead.
class CountOperation extends CommandOperation {
  CountOperation(DbCollection collection,
      {this.query,
      this.limit,
      this.skip,
      this.hint,
      this.hintDocument,
      CountOptions countOptions,
      Map<String, Object> rawOptions})
      : super(collection?.db,
            <String, Object>{...?countOptions?.options, ...?rawOptions},
            collection: collection, aspect: Aspect.readOperation);

  /// A query that selects which documents to count in the collection or view.
  Map<String, Object> query;

  /// The maximum number of matching documents to return.
  int limit;

  /// The number of matching documents to skip before returning results.
  int skip;

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

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyCount: collection?.collectionName,
      if (query != null) keyQuery: query,
      if (limit != null && limit > 0) keyLimit: limit,
      if (skip != null && skip > 0) keySkip: skip,
      if (hint != null)
        keyHint: hint
      else if (hintDocument != null)
        keyHint: hintDocument,
    };
  }

  Future<CountResult> executeDocument() async {
    var result = await super.execute();
    return CountResult(result);
  }
}
