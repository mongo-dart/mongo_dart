import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show
        MongoCollection,
        MongoDartError,
        ServerApiVersion,
        UpdateOneOptions,
        UpdateOneStatement,
        UpdateOperation,
        WriteCommandType,
        WriteResult;

import '../../../../../session/client_session.dart';
import '../open/update_one_operation_open.dart';
import '../v1/update_one_operation_v1.dart';

abstract class UpdateOneOperation extends UpdateOperation {
  @protected
  UpdateOneOperation.protected(
      MongoCollection collection, UpdateOneStatement updateOneStatement,
      {UpdateOneOptions? updateOneOptions, Map<String, Object>? rawOptions})
      : super.protected(
          collection,
          [updateOneStatement],
          ordered: false,
          updateOptions: updateOneOptions,
          rawOptions: rawOptions,
        );

  factory UpdateOneOperation(
      MongoCollection collection, UpdateOneStatement updateOneStatement,
      {UpdateOneOptions? updateOneOptions, Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return UpdateOneOperationV1(
              collection, updateOneStatement.toUpdateOneV1,
              updateOneOptions: updateOneOptions?.toUpdateOneV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return UpdateOneOperationOpen(
        collection, updateOneStatement.toUpdateOneOpen,
        updateOneOptions: updateOneOptions?.toUpdateOneOpen,
        rawOptions: rawOptions);
  }
  Future<WriteResult> executeDocument({ClientSession? session}) async =>
      WriteResult.fromMap(
          WriteCommandType.update, await execute(session: session));
}
