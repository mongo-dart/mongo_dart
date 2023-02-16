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

import '../../../../../database/document_types.dart';
import '../../../../../session/client_session.dart';
import '../open/update_one_operation_open.dart';
import '../v1/update_one_operation_v1.dart';

typedef UpdateOneDocumentRec = (WriteResult writeResult, MongoDocument serverDocument);

abstract class UpdateOneOperation extends UpdateOperation {
  @protected
  UpdateOneOperation.protected(
      MongoCollection collection, UpdateOneStatement updateOneStatement,
      {super.session, UpdateOneOptions? updateOneOptions, super.rawOptions})
      : super.protected(collection, [updateOneStatement],
            ordered: false, updateOptions: updateOneOptions);

  factory UpdateOneOperation(
      MongoCollection collection, UpdateOneStatement updateOneStatement,
      {ClientSession? session,
      UpdateOneOptions? updateOneOptions,
      Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return UpdateOneOperationV1(
              collection, updateOneStatement.toUpdateOneV1,
              session: session,
              updateOneOptions: updateOneOptions?.toUpdateOneV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return UpdateOneOperationOpen(
        collection, updateOneStatement.toUpdateOneOpen,
        session: session,
        updateOneOptions: updateOneOptions?.toUpdateOneOpen,
        rawOptions: rawOptions);
  }

 /*  Future<WriteResult> executeDocument() async =>
      WriteResult.fromMap(WriteCommandType.update, await process()); */
  Future<MongoDocument> executeUpdateOne() async => process();    
      
  Future<UpdateOneDocumentRec> executeDocument() async {
    var ret= await executeUpdateOne( );
    return (WriteResult.fromMap(WriteCommandType.update, ret)
      , ret);
  }
}
