import 'package:mongo_dart/src/commands/base/command_operation.dart';
import 'package:mongo_dart/src/commands/base/operation_base.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/delete_operation/delete_statement.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/mongo_collection.dart';
import 'delete_options.dart';

class DeleteOperation extends CommandOperation {
  DeleteOperation(MongoCollection collection, this.deleteRequests,
      {DeleteOptions? deleteOptions, Map<String, Object>? rawOptions})
      : super(
            collection.db,
            <String, Object>{
              ...?deleteOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation) {
    if (deleteRequests.isEmpty) {
      throw ArgumentError('Delete request required in delete operation');
    }
  }
  List<DeleteStatement> deleteRequests;

  @override
  Map<String, Object> $buildCommand() => <String, Object>{
        keyDelete: collection!.collectionName,
        keyDeletes: [for (var request in deleteRequests) request.toMap()]
      };
}
