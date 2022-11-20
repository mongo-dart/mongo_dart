import 'package:mongo_dart/src/commands/query_and_write_operation_commands/delete_operation/delete_operation.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/write_result.dart';

import '../../../../core/network/abstract/connection_base.dart';
import '../../../../database/mongo_collection.dart';
import '../../../../topology/server.dart';
import 'delete_many_options.dart';
import 'delete_many_statement.dart';

class DeleteManyOperation extends DeleteOperation {
  //DeleteManyStatement deleteRequest;

  DeleteManyOperation(
      MongoCollection collection, DeleteManyStatement deleteRequest,
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
