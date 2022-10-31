import 'package:mongo_dart/mongo_dart_old.dart' show WriteConcern;
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/update_operation/update_options.dart';

class UpdateOneOptions extends UpdateOptions {
  UpdateOneOptions(
      {WriteConcern? writeConcern,
      bool? bypassDocumentValidation,
      String? comment})
      : super(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation,
            comment: comment);
}
