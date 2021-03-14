import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'update_options.dart';
import '../../base/command_operation.dart';

class UpdateOperation extends CommandOperation {
  UpdateOperation(DbCollection collection, this.updates,
      {this.ordered,
      UpdateOptions updateOptions,
      Map<String, Object> rawOptions})
      : super(
            collection.db,
            <String, Object>{
              ...?updateOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation) {
    ordered ??= true;
  }

  /// An array of one or more update statements to perform on the
  /// named collection.
  List<UpdateStatement> updates;

  /// If true, then when an update statement fails, return without performing
  /// the remaining update statements. If false, then when an update fails,
  /// continue with the remaining update statements, if any.
  /// Defaults to true.
  bool ordered = true;

  @override
  Map<String, Object> $buildCommand() => <String, Object>{
        keyUpdate: collection.collectionName,
        keyUpdates: [for (var request in updates) request.toMap()],
        if (ordered) keyOrdered: ordered,
      };
}
