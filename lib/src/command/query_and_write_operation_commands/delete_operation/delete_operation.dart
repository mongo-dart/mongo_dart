import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/delete_statement.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/mongo_collection.dart';
import 'delete_options.dart';

class DeleteOperation extends CommandOperation {
  DeleteOperation(MongoCollection collection, this.deleteRequests,
      {DeleteOptions? deleteOptions, Map<String, Object>? rawOptions})
      : super(
            collection.db,
            {},
            <String, dynamic>{
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
  Command $buildCommand() => <String, dynamic>{
        keyDelete: collection!.collectionName,
        keyDeletes: [for (var request in deleteRequests) request.toMap()]
      };
}
