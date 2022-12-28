import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_operation.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/return_classes/write_result.dart';

import '../../../../core/network/abstract/connection_base.dart';
import '../../../../database/mongo_collection.dart';
import '../../../../topology/server.dart';
import 'insert_one_options.dart';

class InsertOneOperation extends InsertOperation {
  Map<String, Object?> document;

  InsertOneOperation(MongoCollection collection, this.document,
      {InsertOneOptions? insertOneOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [document],
          insertOptions: insertOneOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var ret = await super.execute();
    return WriteResult.fromMap(WriteCommandType.insert, ret)
      ..id = ids.first
      ..document = documents.first;
  }
}
