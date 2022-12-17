import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import '../../../../database/mongo_collection.dart';
import 'update_one_options.dart';
import 'update_one_statement.dart';

class UpdateOneOperation extends UpdateOperation {
  //UpdateOneStatement updateRequest;

  UpdateOneOperation(
      MongoCollection collection, UpdateOneStatement updateOneStatement,
      {UpdateOneOptions? updateOneOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [updateOneStatement],
          ordered: false,
          updateOptions: updateOneOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument() async =>
      WriteResult.fromMap(WriteCommandType.update, await execute());
}
