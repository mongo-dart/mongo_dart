import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/return_classes/write_result.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_operation.dart';

import '../../../../core/network/abstract/connection_base.dart';
import '../../../../database/mongo_collection.dart';
import '../../../../topology/server.dart';
import 'update_many_options.dart';
import 'update_many_statement.dart';

class UpdateManyOperation extends UpdateOperation {
  //UpdateManyStatement updateRequest;

  UpdateManyOperation(
      MongoCollection collection, UpdateManyStatement updateManyStatement,
      {bool? ordered,
      UpdateManyOptions? updateManyOptions,
      Map<String, Object>? rawOptions})
      : super(
          collection,
          [updateManyStatement],
          ordered: ordered,
          updateOptions: updateManyOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var ret = await super.executeOnServer(server);
    return WriteResult.fromMap(WriteCommandType.update, ret);
  }
}
