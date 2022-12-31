import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_options.dart';

import '../open/delete_one_options_open.dart';
import '../v1/delete_one_options_v1.dart';

abstract class DeleteOneOptions extends DeleteOptions {
  @protected
  DeleteOneOptions.protected({WriteConcern? writeConcern, String? comment})
      : super.protected(writeConcern: writeConcern, comment: comment);

  factory DeleteOneOptions(
      {ServerApi? serverApi,
      WriteConcern? writeConcern,
      bool? bypassDocumentValidation = false,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteOneOptionsV1(writeConcern: writeConcern, comment: comment);
    }
    return DeleteOneOptionsOpen(writeConcern: writeConcern, comment: comment);
  }

  DeleteOneOptionsOpen get toDeleteOneOpen => this is DeleteOneOptionsOpen
      ? this as DeleteOneOptionsOpen
      : DeleteOneOptionsOpen(writeConcern: writeConcern, comment: comment);

  DeleteOneOptionsV1 get toDeleteOneV1 => this is DeleteOneOptionsV1
      ? this as DeleteOneOptionsV1
      : DeleteOneOptionsV1(writeConcern: writeConcern, comment: comment);
}
