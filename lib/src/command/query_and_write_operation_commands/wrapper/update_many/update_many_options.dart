import 'package:mongo_dart/src/command/parameters/write_concern.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/update_options.dart';

class UpdateManyOptions extends UpdateOptions {
  UpdateManyOptions(
      {WriteConcern? writeConcern,
      bool? bypassDocumentValidation,
      String? comment})
      : super(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation,
            comment: comment);
}
