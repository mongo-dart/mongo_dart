import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/delete_operation.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/write_result.dart';

import '../../../../database/base/mongo_collection.dart';
import 'delete_one_options.dart';
import 'delete_one_statement.dart';

class DeleteOneOperation extends DeleteOperation {
  //DeleteOneStatement deleteRequest;

  DeleteOneOperation(
      MongoCollection collection, DeleteOneStatement deleteRequest,
      {DeleteOneOptions? deleteOneOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [deleteRequest],
          deleteOptions: deleteOneOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument() async =>
      WriteResult.fromMap(WriteCommandType.delete, await execute());
}
