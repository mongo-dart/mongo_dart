import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_operation.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/bulk_write_result.dart';

import '../../../../database/mongo_collection.dart';
import 'insert_many_options.dart';

class InsertManyOperation extends InsertOperation {
  InsertManyOperation(
      MongoCollection collection, List<Map<String, Object?>> documents,
      {InsertManyOptions? insertManyOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          documents,
          insertOptions: insertManyOptions,
          rawOptions: rawOptions,
        ) {
    if (documents.isEmpty) {
      throw ArgumentError(
          'At least one document required in InsertManyOperation');
    }
  }

  Future<BulkWriteResult> executeDocument() async {
    return BulkWriteResult.fromMap(WriteCommandType.insert, await execute())
      ..ids = ids
      ..documents = documents;
  }
}
