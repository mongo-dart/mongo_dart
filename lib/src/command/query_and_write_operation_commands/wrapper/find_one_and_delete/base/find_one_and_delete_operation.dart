import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../../../session/client_session.dart';
import '../../../../../unions/hint_union.dart';
import '../../../../../unions/query_union.dart';
import '../../../../base/operation_base.dart';
import '../open/find_one_and_delete_operation_open.dart';
import '../v1/find_one_and_delete_operation_v1.dart';
import 'find_one_and_delete_options.dart';

typedef FindOneAndDeleteDocumentRec = (
  FindAndModifyResult findAndModifyResult,
  MongoDocument serverDocument
);

abstract base class FindOneAndDeleteOperation extends FindAndModifyOperation {
  @protected
  FindOneAndDeleteOperation.protected(
      MongoCollection collection, QueryUnion query,
      {super.fields,
      super.sort,
      super.session,
      super.hint,
      FindOneAndDeleteOptions? findOneAndDeleteOptions,
      super.rawOptions})
      : super.protected(collection,
            query: query,
            remove: true,
            findAndModifyOptions: findOneAndDeleteOptions);

  factory FindOneAndDeleteOperation(
      MongoCollection collection, QueryUnion query,
      {ProjectionDocument? fields,
      IndexDocument? sort,
      ClientSession? session,
      HintUnion? hint,
      FindOneAndDeleteOptions? findOneAndDeleteOptions,
      Options? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return FindOneAndDeleteOperationV1(collection, query,
              fields: fields,
              sort: sort,
              session: session,
              hint: hint,
              findOneAndDeleteOptions:
                  findOneAndDeleteOptions?.toFindOneAndDeleteOptionsV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return FindOneAndDeleteOperationOpen(collection, query,
        fields: fields,
        sort: sort,
        session: session,
        hint: hint,
        findOneAndDeleteOptions:
            findOneAndDeleteOptions?.toFindOneAndDeleteOptionsOpen,
        rawOptions: rawOptions);
  }

  Future<MongoDocument> executeFindOneAndDelete() async => process();

  Future<FindOneAndDeleteDocumentRec> executeDocument() async {
    var ret = await executeFindOneAndDelete();
    return (FindAndModifyResult(ret), ret);
  }
}
