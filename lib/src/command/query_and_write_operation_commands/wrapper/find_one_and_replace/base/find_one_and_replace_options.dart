import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../open/find_one_and_replace_options_open.dart';
import '../v1/find_one_and_replace_options_v1.dart';

abstract class FindOneAndReplaceOptions extends FindAndModifyOptions {
  @protected
  FindOneAndReplaceOptions.protected(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();

  factory FindOneAndReplaceOptions(
      {ServerApi? serverApi,
      bool? bypassDocumentValidation = false,
      WriteConcern? writeConcern,
      int? maxTimeMS,
      CollationOptions? collation,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return FindOneAndReplaceOptionsV1(
          bypassDocumentValidation: bypassDocumentValidation,
          writeConcern: writeConcern,
          maxTimeMS: maxTimeMS,
          collation: collation,
          comment: comment);
    }
    return FindOneAndReplaceOptionsOpen(
        bypassDocumentValidation: bypassDocumentValidation,
        writeConcern: writeConcern,
        maxTimeMS: maxTimeMS,
        collation: collation,
        comment: comment);
  }

  FindOneAndReplaceOptionsOpen get toFindOneAndReplaceOptionsOpen =>
      this is FindOneAndReplaceOptionsOpen
          ? this as FindOneAndReplaceOptionsOpen
          : FindOneAndReplaceOptionsOpen(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);

  FindOneAndReplaceOptionsV1 get toFindOneAndReplaceOptionsV1 =>
      this is FindOneAndReplaceOptionsV1
          ? this as FindOneAndReplaceOptionsV1
          : FindOneAndReplaceOptionsV1(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);
}
