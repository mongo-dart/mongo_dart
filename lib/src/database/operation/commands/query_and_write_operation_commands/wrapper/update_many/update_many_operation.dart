import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import 'update_many_options.dart';
import 'update_many_statement.dart';

class UpdateManyOperation extends UpdateOperation {
  UpdateManyStatement updateRequest;

  UpdateManyOperation(
      DbCollection collection, UpdateManyStatement updateManyStatement,
      {bool ordered,
      UpdateManyOptions updateManyOptions,
      Map<String, Object> rawOptions})
      : super(
          collection,
          [updateManyStatement],
          ordered: ordered,
          updateOptions: updateManyOptions,
          rawOptions: rawOptions,
        ) {
    if (updateManyStatement == null) {
      throw ArgumentError('Update Statement needed in updateOne() method');
    }
  }

  Future<WriteResult> executeDocument() async {
    var ret = await super.execute();
    return WriteResult.fromMap(WriteCommandType.update, ret);
  }
}
