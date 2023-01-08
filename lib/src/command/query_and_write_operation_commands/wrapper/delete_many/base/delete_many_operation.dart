import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_operation.dart';

import '../../../../../session/client_session.dart';
import '../../../../../topology/server.dart';
import '../open/delete_many_operation_open.dart';
import '../v1/delete_many_operation_v1.dart';

abstract class DeleteManyOperation extends DeleteOperation {
  @protected
  DeleteManyOperation.protected(
      MongoCollection collection, DeleteManyStatement deleteRequest,
      {DeleteManyOptions? deleteManyOptions, Map<String, Object>? rawOptions})
      : super.protected(
          collection,
          [deleteRequest],
          deleteOptions: deleteManyOptions,
          rawOptions: rawOptions,
        );

  factory DeleteManyOperation(
      MongoCollection collection, DeleteManyStatement deleteManyStatement,
      {DeleteManyOptions? deleteManyOptions, Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return DeleteManyOperationV1(
              collection, deleteManyStatement.toDeleteManyV1,
              deleteManyOptions: deleteManyOptions?.toDeleteManyV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return DeleteManyOperationOpen(
        collection, deleteManyStatement.toDeleteManyOpen,
        deleteManyOptions: deleteManyOptions?.toDeleteManyOpen,
        rawOptions: rawOptions);
  }
  Future<WriteResult> executeDocument(Server server,
      {ClientSession? session}) async {
    var ret = await super.execute(session: session);
    return WriteResult.fromMap(WriteCommandType.delete, ret);
  }
}
