import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../open/update_one_options_open.dart';
import '../v1/update_one_options_v1.dart';

abstract class UpdateOneOptions extends UpdateOptions {
  @protected
  UpdateOneOptions.protected(
      {WriteConcern? writeConcern,
      bool? bypassDocumentValidation,
      String? comment})
      : super.protected(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation,
            comment: comment);

  factory UpdateOneOptions(
      {ServerApi? serverApi,
      WriteConcern? writeConcern,
      bool? bypassDocumentValidation = false,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return UpdateOneOptionsV1(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);
    }
    return UpdateOneOptionsOpen(
        writeConcern: writeConcern,
        bypassDocumentValidation: bypassDocumentValidation,
        comment: comment);
  }

  UpdateOneOptionsOpen get toUpdateOneOpen => this is UpdateOneOptionsOpen
      ? this as UpdateOneOptionsOpen
      : UpdateOneOptionsOpen(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);

  UpdateOneOptionsV1 get toUpdateOneV1 => this is UpdateOneOptionsV1
      ? this as UpdateOneOptionsV1
      : UpdateOneOptionsV1(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);
}
