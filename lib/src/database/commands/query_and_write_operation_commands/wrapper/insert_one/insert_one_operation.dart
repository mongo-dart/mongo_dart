import 'package:mongo_dart/mongo_dart.dart' show DbCollection;
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/insert_operation/insert_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/write_result.dart';

import 'insert_one_options.dart';

class InsertOneOperation extends InsertOperation {
  Map<String, Object> document;

  InsertOneOperation(DbCollection collection, this.document,
      {InsertOneOptions insertOneOptions, Map<String, Object> rawOptions})
      : super(
          collection,
          [document],
          insertOptions: insertOneOptions,
          rawOptions: rawOptions,
        ) {
    if (document == null) {
      throw ArgumentError('Document required in insertOne() method');
    }
  }

  Future<WriteResult> executeDocument() async {
    var ret = await super.execute();
    return WriteResult.fromMap(WriteCommandType.insert, ret)
      ..id = ids.first
      ..document = documents.first;
  }
}
