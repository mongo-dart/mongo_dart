import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../update_many_operation_open.dart';
import '../update_many_operation_v1.dart';

abstract class UpdateManyOperation extends UpdateOperation {
  @protected
  UpdateManyOperation.protected(
      MongoCollection collection, UpdateManyStatement updateManyStatement,
      {bool? ordered,
      UpdateManyOptions? updateManyOptions,
      Map<String, Object>? rawOptions})
      : super.protected(
          collection,
          [updateManyStatement],
          ordered: ordered,
          updateOptions: updateManyOptions,
          rawOptions: rawOptions,
        );

  factory UpdateManyOperation(
      MongoCollection collection, UpdateManyStatement updateManyStatement,
      {bool? ordered,
      UpdateManyOptions? updateManyOptions,
      Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return UpdateManyOperationV1(
              collection, updateManyStatement.toUpdateManyV1,
              ordered: ordered,
              updateManyOptions: updateManyOptions?.toUpdateManyV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return UpdateManyOperationOpen(
        collection, updateManyStatement.toUpdateManyOpen,
        ordered: ordered,
        updateManyOptions: updateManyOptions?.toUpdateManyOpen,
        rawOptions: rawOptions);
  }

  Future<WriteResult> executeDocument() async =>
      WriteResult.fromMap(WriteCommandType.update, await execute());
}
