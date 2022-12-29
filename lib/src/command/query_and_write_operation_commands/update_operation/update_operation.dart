import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/mongo_collection.dart';
import 'update_options.dart';
import '../../base/command_operation.dart';

class UpdateOperation extends CommandOperation {
  UpdateOperation(MongoCollection collection, this.updates,
      {bool? ordered,
      UpdateOptions? updateOptions,
      Map<String, Object>? rawOptions})
      : ordered = ordered ?? true,
        super(
            collection.db,
            {},
            <String, dynamic>{
              ...?updateOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation);

  /// An array of one or more update statements to perform on the
  /// named collection.
  List<UpdateStatement> updates;

  /// If true, then when an update statement fails, return without performing
  /// the remaining update statements. If false, then when an update fails,
  /// continue with the remaining update statements, if any.
  /// Defaults to true.
  bool ordered;

  @override
  Command $buildCommand() => <String, dynamic>{
        keyUpdate: collection!.collectionName,
        keyUpdates: [for (var request in updates) request.toMap()],
        if (ordered) keyOrdered: ordered,
      };
}
