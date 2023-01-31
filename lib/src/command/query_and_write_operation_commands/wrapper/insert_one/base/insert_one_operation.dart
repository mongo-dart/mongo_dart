import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show
        InsertOneOptions,
        InsertOperation,
        MongoCollection,
        MongoDartError,
        MongoDocument,
        WriteCommandType,
        WriteResult;
import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/server_api_version.dart';

import '../../../../../session/client_session.dart';
import '../open/insert_one_operation_open.dart';
import '../v1/insert_one_operation_v1.dart';

typedef InsertOneRec = (MongoDocument serverDocument, MongoDocument insertedDocument, dynamic id);
typedef InsertOneDocumentRec = (WriteResult writeResult, MongoDocument serverDocument, MongoDocument insertedDocument, dynamic id);

abstract class InsertOneOperation extends InsertOperation {
  Map<String, dynamic> document;

  @protected
  InsertOneOperation.protected(MongoCollection collection, this.document,
      {InsertOneOptions? insertOneOptions, Options? rawOptions})
      : super.protected(
          collection,
          [document],
          insertOptions: insertOneOptions,
          rawOptions: rawOptions,
        );

  factory InsertOneOperation(MongoCollection collection, MongoDocument document,
      {InsertOneOptions? insertOneOptions, Options? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return InsertOneOperationV1(collection, document,
              insertOneOptions: insertOneOptions?.toOneV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return InsertOneOperationOpen(collection, document,
        insertOneOptions: insertOneOptions?.toOneOpen, rawOptions: rawOptions);
  }

   Future<InsertOneRec> executeInsertOne({ClientSession? session}) async {
    var (ret, documents, ids) = await executeInsert(session: session);
    return (ret, documents.first, ids.first);
  }

  Future<InsertOneDocumentRec> executeDocument({ClientSession? session}) async {
    var (ret, document, id) = await executeInsertOne(session: session);
    return (WriteResult.fromMap(WriteCommandType.insert, ret)
      , ret, document, id);
  }
}
