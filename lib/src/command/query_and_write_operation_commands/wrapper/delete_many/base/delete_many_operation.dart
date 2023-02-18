import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_operation.dart';

import '../../../../../session/client_session.dart';
import '../open/delete_many_operation_open.dart';
import '../v1/delete_many_operation_v1.dart';

typedef DeleteManyDocumentRec = (WriteResult writeResult, MongoDocument serverDocument);

abstract class DeleteManyOperation extends DeleteOperation {
  @protected
  DeleteManyOperation.protected(
      MongoCollection collection, DeleteManyStatement deleteRequest,
      {super.session,
      DeleteManyOptions? deleteManyOptions,
      Map<String, Object>? rawOptions})
      : super.protected(
          collection,
          [deleteRequest],
          deleteOptions: deleteManyOptions,
          rawOptions: rawOptions,
        );

  factory DeleteManyOperation(
      MongoCollection collection, DeleteManyStatement deleteManyStatement,
      {ClientSession? session,
      DeleteManyOptions? deleteManyOptions,
      Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return DeleteManyOperationV1(
              collection, deleteManyStatement.toDeleteManyV1,
              session: session,
              deleteManyOptions: deleteManyOptions?.toDeleteManyV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return DeleteManyOperationOpen(
        collection, deleteManyStatement.toDeleteManyOpen,
        session: session,
        deleteManyOptions: deleteManyOptions?.toDeleteManyOpen,
        rawOptions: rawOptions);
  }
       Future<MongoDocument> executeDeleteMany() async => process();    

  Future<DeleteManyDocumentRec> executeDocument() async {  
    var ret= await executeDeleteMany( );
    return ( WriteResult.fromMap(WriteCommandType.delete, ret), ret);
  }


 
}
