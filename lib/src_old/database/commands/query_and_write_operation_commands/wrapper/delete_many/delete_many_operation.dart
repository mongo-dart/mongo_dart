import 'package:mongo_dart/mongo_dart_old.dart' show DbCollection;
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/delete_operation/delete_operation.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/return_classes/write_result.dart';

import '../../../../../../src/core/network/abstract/connection_base.dart';
import '../../../../../../src/core/topology/server.dart';
import 'delete_many_options.dart';
import 'delete_many_statement.dart';

class DeleteManyOperation extends DeleteOperation {
  //DeleteManyStatement deleteRequest;

  DeleteManyOperation(
      DbCollection collection, DeleteManyStatement deleteRequest,
      {DeleteManyOptions? deleteManyOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [deleteRequest],
          deleteOptions: deleteManyOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var ret = await super.execute(server, connection: connection);
    return WriteResult.fromMap(WriteCommandType.delete, ret);
  }
}
