import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../open/find_one_and_update_options_open.dart';
import '../v1/find_one_and_update_options_v1.dart';

abstract class FindOneAndUpdateOptions extends FindAndModifyOptions {
  @protected
  FindOneAndUpdateOptions.protected(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();

  factory FindOneAndUpdateOptions(
      {ServerApi? serverApi,
      bool? bypassDocumentValidation = false,
      WriteConcern? writeConcern,
      int? maxTimeMS,
      CollationOptions? collation,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return FindOneAndUpdateOptionsV1(
          bypassDocumentValidation: bypassDocumentValidation,
          writeConcern: writeConcern,
          maxTimeMS: maxTimeMS,
          collation: collation,
          comment: comment);
    }
    return FindOneAndUpdateOptionsOpen(
        bypassDocumentValidation: bypassDocumentValidation,
        writeConcern: writeConcern,
        maxTimeMS: maxTimeMS,
        collation: collation,
        comment: comment);
  }

  FindOneAndUpdateOptionsOpen get toFindOneAndUpdateOptionsOpen =>
      this is FindOneAndUpdateOptionsOpen
          ? this as FindOneAndUpdateOptionsOpen
          : FindOneAndUpdateOptionsOpen(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);

  FindOneAndUpdateOptionsV1 get toFindOneAndUpdateOptionsV1 =>
      this is FindOneAndUpdateOptionsV1
          ? this as FindOneAndUpdateOptionsV1
          : FindOneAndUpdateOptionsV1(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);
}
