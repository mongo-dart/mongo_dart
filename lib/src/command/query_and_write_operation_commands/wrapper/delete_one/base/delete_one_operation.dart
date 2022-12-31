import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_operation.dart';

import '../open/delete_one_operation_open.dart';
import '../v1/delete_one_operation_v1.dart';

abstract class DeleteOneOperation extends DeleteOperation {
  @protected
  DeleteOneOperation.protected(
      MongoCollection collection, DeleteOneStatement deleteRequest,
      {DeleteOneOptions? deleteOneOptions, Map<String, Object>? rawOptions})
      : super.protected(
          collection,
          [deleteRequest],
          deleteOptions: deleteOneOptions,
          rawOptions: rawOptions,
        );

  factory DeleteOneOperation(
      MongoCollection collection, DeleteOneStatement deleteOneStatement,
      {DeleteOneOptions? deleteOneOptions, Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return DeleteOneOperationV1(
              collection, deleteOneStatement.toDeleteOneV1,
              deleteOneOptions: deleteOneOptions?.toDeleteOneV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return DeleteOneOperationOpen(
        collection, deleteOneStatement.toDeleteOneOpen,
        deleteOneOptions: deleteOneOptions?.toDeleteOneOpen,
        rawOptions: rawOptions);
  }
  Future<WriteResult> executeDocument() async =>
      WriteResult.fromMap(WriteCommandType.delete, await execute());
}
