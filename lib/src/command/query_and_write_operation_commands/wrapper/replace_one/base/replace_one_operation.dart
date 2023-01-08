import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/replace_one/open/replace_one_operation_open.dart';

import '../../../../../session/client_session.dart';
import '../v1/replace_one_operation_v1.dart';

abstract class ReplaceOneOperation extends UpdateOperation {
  @protected
  ReplaceOneOperation.protected(
      MongoCollection collection, ReplaceOneStatement replaceOneStatement,
      {ReplaceOneOptions? replaceOneOptions, Map<String, Object>? rawOptions})
      : super.protected(
          collection,
          [replaceOneStatement],
          ordered: false,
          updateOptions: replaceOneOptions,
          rawOptions: rawOptions,
        );

  factory ReplaceOneOperation(
      MongoCollection collection, ReplaceOneStatement replaceOneStatement,
      {ReplaceOneOptions? replaceOneOptions, Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return ReplaceOneOperationV1(
              collection, replaceOneStatement.toReplaceOneV1,
              replaceOneOptions: replaceOneOptions?.toReplaceOneV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return ReplaceOneOperationOpen(
        collection, replaceOneStatement.toReplaceOneOpen,
        replaceOneOptions: replaceOneOptions?.toReplaceOneOpen,
        rawOptions: rawOptions);
  }

  Future<WriteResult> executeDocument({ClientSession? session}) async =>
      WriteResult.fromMap(
          WriteCommandType.update, await execute(session: session));
}
