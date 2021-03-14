import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'distinct_options.dart';
import '../../base/command_operation.dart';
import 'distinct_result.dart';

/// Collection is the collection on which the operation is performed
/// In case of admin/diagnostic pipeline which does not require an underlying
/// collection, the db parameter must be passed instead.
class DistinctOperation extends CommandOperation {
  DistinctOperation(DbCollection collection, this.key,
      {this.query,
      DistinctOptions distinctOptions,
      Map<String, Object> rawOptions})
      : super(collection?.db,
            <String, Object>{...?distinctOptions?.options, ...?rawOptions},
            collection: collection, aspect: Aspect.readOperation);

  /// The field for which to return distinct values.
  String key;

  /// A query that selects which documents to count in the collection or view.
  Map<String, Object> query;

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyDistinct: collection?.collectionName,
      keyKey: key,
      if (query != null) keyQuery: query,
    };
  }

  Future<DistinctResult> executeDocument() async {
    var result = await super.execute();
    return DistinctResult(result);
  }
}
