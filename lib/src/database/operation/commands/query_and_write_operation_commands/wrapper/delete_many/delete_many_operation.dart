import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/delete_operation/delete_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/write_result.dart';

import 'delete_many_options.dart';
import 'delete_many_statement.dart';

class DeleteManyOperation extends DeleteOperation {
  DeleteManyStatement deleteRequest;

  DeleteManyOperation(DbCollection collection, DeleteManyStatement deleteRequest,
      {DeleteManyOptions deleteManyOptions, Map<String, Object> rawOptions})
      : super(
          collection,
          [deleteRequest],
          deleteOptions: deleteManyOptions,
          rawOptions: rawOptions,
        ) {
    if (deleteRequest == null) {
      throw ArgumentError('Delete Request required in deleteMany() method');
    }
  }

  Future<WriteResult> executeDocument() async {
    var ret = await super.execute();
    return WriteResult.fromMap(WriteCommandType.delete, ret);
  }
}
