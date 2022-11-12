import 'package:mongo_dart/mongo_dart_old.dart' show DbCollection;
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import '../../../../../../src/core/network/abstract/connection_base.dart';
import '../../../../../../src/core/topology/server.dart';
import 'replace_one_options.dart';
import 'replace_one_statement.dart';

class ReplaceOneOperation extends UpdateOperation {
  //ReplaceOneStatement replaceOneStatement;

  ReplaceOneOperation(
      DbCollection collection, ReplaceOneStatement replaceOneStatement,
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
    var ret = await super.execute(server, connection: connection);
    return WriteResult.fromMap(WriteCommandType.update, ret);
  }
}
