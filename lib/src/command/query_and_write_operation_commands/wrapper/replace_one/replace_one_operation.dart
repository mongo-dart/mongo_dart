import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/update_operation.dart';

import '../../../../database/base/mongo_collection.dart';
import 'replace_one_options.dart';
import 'replace_one_statement.dart';

class ReplaceOneOperation extends UpdateOperation {
  //ReplaceOneStatement replaceOneStatement;

  ReplaceOneOperation(
      MongoCollection collection, ReplaceOneStatement replaceOneStatement,
      {ReplaceOneOptions? replaceOneOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [replaceOneStatement],
          ordered: false,
          updateOptions: replaceOneOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument() async =>
      WriteResult.fromMap(WriteCommandType.update, await execute());
}
