import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../open/find_one_and_delete_options_open.dart';
import '../v1/find_one_and_delete_options_v1.dart';

abstract class FindOneAndDeleteOptions extends FindAndModifyOptions {
  @protected
  FindOneAndDeleteOptions.protected(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();

  factory FindOneAndDeleteOptions(
      {ServerApi? serverApi,
      bool? bypassDocumentValidation = false,
      WriteConcern? writeConcern,
      int? maxTimeMS,
      CollationOptions? collation,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return FindOneAndDeleteOptionsV1(
          bypassDocumentValidation: bypassDocumentValidation,
          writeConcern: writeConcern,
          maxTimeMS: maxTimeMS,
          collation: collation,
          comment: comment);
    }
    return FindOneAndDeleteOptionsOpen(
        bypassDocumentValidation: bypassDocumentValidation,
        writeConcern: writeConcern,
        maxTimeMS: maxTimeMS,
        collation: collation,
        comment: comment);
  }

  FindOneAndDeleteOptionsOpen get toFindOneAndDeleteOptionsOpen =>
      this is FindOneAndDeleteOptionsOpen
          ? this as FindOneAndDeleteOptionsOpen
          : FindOneAndDeleteOptionsOpen(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);

  FindOneAndDeleteOptionsV1 get toFindOneAndDeleteOptionsV1 =>
      this is FindOneAndDeleteOptionsV1
          ? this as FindOneAndDeleteOptionsV1
          : FindOneAndDeleteOptionsV1(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);
}
