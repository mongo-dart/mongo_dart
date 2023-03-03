import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../../../session/client_session.dart';
import '../../../../../utils/hint_union.dart';
import '../../../../../utils/query_union.dart';
import '../../../../base/operation_base.dart';
import '../../../update_operation/base/update_union.dart';
import '../open/find_one_and_update_operation_open.dart';
import '../v1/find_one_and_update_operation_v1.dart';
import 'find_one_and_update_options.dart';

typedef FindOneAndUpdateDocumentRec = (FindAndModifyResult findAndModifyResult, MongoDocument serverDocument);

abstract class FindOneAndUpdateOperation extends FindAndModifyOperation {
  @protected
  FindOneAndUpdateOperation.protected(
      super. collection, 
      {super.query,super.update,
            super.fields,
        super.sort,
        super. upsert,
      super.returnNew,
      super.arrayFilters,
      super.session,
      super.hint,
      FindOneAndUpdateOptions? findOneAndUpdateOptions,
      super.rawOptions})
      : super.protected(remove: false,
         
         
          findAndModifyOptions: findOneAndUpdateOptions
        );

  factory FindOneAndUpdateOperation(
      MongoCollection collection, 
      {QueryUnion query  = const QueryUnion(<String, dynamic>{}),
        UpdateUnion? update,
       ProjectionDocument? fields,
   IndexDocument? sort,
         bool? upsert,
      bool? returnNew,
      List<ArrayFilter>? arrayFilters,
      ClientSession? session,
      HintUnion? hint,
      FindOneAndUpdateOptions? findOneAndUpdateOptions,
      Options? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return FindOneAndUpdateOperationV1(
              collection, 
              query: query,  update: update, fields: fields,
      sort: sort,  upsert:upsert,
    
     returnNew: returnNew,
     
    
      arrayFilters: arrayFilters,
              session: session,
              findOneAndUpdateOptions: findOneAndUpdateOptions?.toFindOneAndUpdateOptionsV1,
 hint: hint,          rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return FindOneAndUpdateOperationOpen(
          collection, 
              query: query,  update: update, fields: fields,
      sort: sort,  upsert:upsert,
     returnNew: returnNew,
         arrayFilters: arrayFilters,
              session: session,
              findOneAndUpdateOptions: findOneAndUpdateOptions?.toFindOneAndUpdateOptionsOpen,
 hint: hint,          rawOptions: rawOptions);
  }

  Future<MongoDocument> executeFindOneAndUpdate() async => process();    

  Future<FindOneAndUpdateDocumentRec> executeDocument() async {
            var ret= await executeFindOneAndUpdate( );
    return (FindAndModifyResult(ret),ret);
  }   
}
