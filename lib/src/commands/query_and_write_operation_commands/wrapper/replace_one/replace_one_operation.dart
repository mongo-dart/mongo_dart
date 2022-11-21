import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import '../../../../core/network/abstract/connection_base.dart';
import '../../../../database/mongo_collection.dart';
import '../../../../topology/server.dart';
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

  Future<WriteResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var ret = await super.executeOnServer(server);
    return WriteResult.fromMap(WriteCommandType.update, ret);
  }
}
