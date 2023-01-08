import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show
        BulkWriteResult,
        InsertManyOptions,
        InsertOperation,
        MongoCollection,
        MongoDartError,
        MongoDocument,
        WriteCommandType;

import '../../../../../server_api_version.dart';
import '../../../../../session/client_session.dart';
import '../../../../base/operation_base.dart';
import '../open/insert_many_operation_open.dart';
import '../v1/insert_many_operation_v1.dart';

abstract class InsertManyOperation extends InsertOperation {
  @protected
  InsertManyOperation.protected(
      MongoCollection collection, List<MongoDocument> documents,
      {InsertManyOptions? insertManyOptions, Options? rawOptions})
      : super.protected(
          collection,
          documents,
          insertOptions: insertManyOptions,
          rawOptions: rawOptions,
        ) {
    if (documents.isEmpty) {
      throw ArgumentError(
          'At least one document required in InsertManyOperation');
    }
  }

  factory InsertManyOperation(
      MongoCollection collection, List<MongoDocument> documents,
      {InsertManyOptions? insertManyOptions, Options? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return InsertManyOperationV1(collection, documents,
              insertManyOptions: insertManyOptions?.toManyV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return InsertManyOperationOpen(collection, documents,
        insertManyOptions: insertManyOptions?.toManyOpen,
        rawOptions: rawOptions);
  }

  Future<BulkWriteResult> executeDocument({ClientSession? session}) async =>
      BulkWriteResult.fromMap(
          WriteCommandType.insert, await execute(session: session))
        ..ids = ids
        ..documents = documents;
}
