                                                               import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/insert_operation/insert_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/bulk_write_result.dart';

import 'insert_many_options.dart';

class InsertManyOperation extends InsertOperation {
  InsertManyOperation(
      DbCollection collection, List<Map<String, Object>> documents,
      {InsertManyOptions insertManyOptions, Map<String, Object> rawOptions})
      : super(
          collection,
          documents,
          insertOptions: insertManyOptions,
          rawOptions: rawOptions,
        ) {
    if (documents == null || documents.isEmpty) {
      throw ArgumentError(
          'At least one document required in InsertManyOperation');
    }
  }

  Future<BulkWriteResult> executeDocument() async {
    var ret = await super.execute();
    return BulkWriteResult.fromMap(WriteCommandType.insert, ret)
      ..ids = ids
      ..documents = documents;
  }
}
