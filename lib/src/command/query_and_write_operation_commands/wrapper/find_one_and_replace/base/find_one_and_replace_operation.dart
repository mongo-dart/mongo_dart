import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../../../session/client_session.dart';
import '../../../../../utils/hint_union.dart';
import '../../../../../utils/query_union.dart';
import '../../../../base/operation_base.dart';
import '../../../update_operation/base/update_union.dart';
import '../open/find_one_and_replace_operation_open.dart';
import '../v1/find_one_and_replace_operation_v1.dart';
import 'find_one_and_replace_options.dart';

typedef FindOneAndReplaceDocumentRec = (
  FindAndModifyResult findAndModifyResult,
  MongoDocument serverDocument
);

abstract base class FindOneAndReplaceOperation extends FindAndModifyOperation {
  @protected
  FindOneAndReplaceOperation.protected(
      super.collection, QueryUnion query, MongoDocument replacement,
      {super.fields,
      super.sort,
      super.upsert,
      super.returnNew,
      super.session,
      super.hint,
      FindOneAndReplaceOptions? findOneAndReplaceOptions,
      super.rawOptions})
      : super.protected(
            query: query,
            update: UpdateUnion(replacement),
            remove: false,
            findAndModifyOptions: findOneAndReplaceOptions);

  factory FindOneAndReplaceOperation(
      MongoCollection collection, QueryUnion query, MongoDocument replacement,
      {ProjectionDocument? fields,
      IndexDocument? sort,
      bool? upsert,
      bool? returnNew,
      ClientSession? session,
      HintUnion? hint,
      FindOneAndReplaceOptions? findOneAndReplaceOptions,
      Options? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return FindOneAndReplaceOperationV1(collection, query, replacement,
              fields: fields,
              sort: sort,
              upsert: upsert,
              returnNew: returnNew,
              session: session,
              findOneAndReplaceOptions:
                  findOneAndReplaceOptions?.toFindOneAndReplaceOptionsV1,
              hint: hint,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return FindOneAndReplaceOperationOpen(collection, query, replacement,
        fields: fields,
        sort: sort,
        upsert: upsert,
        returnNew: returnNew,
        session: session,
        findOneAndReplaceOptions:
            findOneAndReplaceOptions?.toFindOneAndReplaceOptionsOpen,
        hint: hint,
        rawOptions: rawOptions);
  }

  Future<MongoDocument> executeFindOneAndReplace() async => process();

  Future<FindOneAndReplaceDocumentRec> executeDocument() async {
    var ret = await executeFindOneAndReplace();
    return (FindAndModifyResult(ret), ret);
  }
}
