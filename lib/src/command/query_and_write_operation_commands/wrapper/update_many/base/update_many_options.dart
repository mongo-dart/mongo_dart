import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../update_many_options_open.dart';
import '../update_many_options_v1.dart';

abstract class UpdateManyOptions extends UpdateOptions {
  @protected
  UpdateManyOptions.protected(
      {WriteConcern? writeConcern,
      bool? bypassDocumentValidation,
      String? comment})
      : super.protected(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation,
            comment: comment);

  factory UpdateManyOptions(
      {ServerApi? serverApi,
      WriteConcern? writeConcern,
      bool? bypassDocumentValidation = false,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return UpdateManyOptionsV1(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);
    }
    return UpdateManyOptionsOpen(
        writeConcern: writeConcern,
        bypassDocumentValidation: bypassDocumentValidation,
        comment: comment);
  }

  UpdateManyOptionsOpen get toUpdateManyOpen => this is UpdateManyOptionsOpen
      ? this as UpdateManyOptionsOpen
      : UpdateManyOptionsOpen(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);

  UpdateManyOptionsV1 get toUpdateManyV1 => this is UpdateManyOptionsV1
      ? this as UpdateManyOptionsV1
      : UpdateManyOptionsV1(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);
}
