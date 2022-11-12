import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import '../../../../core/network/abstract/connection_base.dart';
import '../../../../database/dbcollection.dart';
import '../../../../topology/server.dart';
import 'update_one_options.dart';
import 'update_one_statement.dart';

class UpdateOneOperation extends UpdateOperation {
  //UpdateOneStatement updateRequest;

  UpdateOneOperation(
      DbCollection collection, UpdateOneStatement updateOneStatement,
      {UpdateOneOptions? updateOneOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [updateOneStatement],
          ordered: false,
          updateOptions: updateOneOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var ret = await super.execute(server, connection: connection);
    return WriteResult.fromMap(WriteCommandType.update, ret);
  }
}
