import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import 'update_one_options.dart';
import 'update_one_statement.dart';

class UpdateOneOperation extends UpdateOperation {
  UpdateOneStatement updateRequest;

  UpdateOneOperation(
      DbCollection collection, UpdateOneStatement updateOneStatement,
      {UpdateOneOptions updateOneOptions, Map<String, Object> rawOptions})
      : super(
          collection,
          [updateOneStatement],
          ordered: false,
          updateOptions: updateOneOptions,
          rawOptions: rawOptions,
        ) {
    if (updateOneStatement == null) {
      throw ArgumentError('Update Statement needed in updateOne() method');
    }
  }

  Future<WriteResult> executeDocument() async {
    var ret = await super.execute();
    return WriteResult.fromMap(WriteCommandType.update, ret);
  }
}
