import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/mongo_collection.dart';
import 'distinct_options.dart';
import '../../base/command_operation.dart';
import 'distinct_result.dart';

/// Collection is the collection on which the operation is performed
/// In case of admin/diagnostic pipeline which does not require an underlying
/// collection, the db parameter must be passed instead.
class DistinctOperation extends CommandOperation {
  DistinctOperation(MongoCollection collection, this.key,
      {this.query,
      DistinctOptions? distinctOptions,
      Map<String, Object>? rawOptions})
      : super(collection.db, {},
            <String, Object>{...?distinctOptions?.options, ...?rawOptions},
            collection: collection, aspect: Aspect.readOperation);

  /// The field for which to return distinct values.
  String key;

  /// A query that specifies the documents from which to retrieve
  /// the distinct values.
  Map<String, Object?>? query;

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyDistinct: collection!.collectionName,
      keyKey: key,
      if (query != null) keyQuery: query!,
    };
  }

  Future<DistinctResult> executeDocument() async =>
      DistinctResult(await super.execute());
}
