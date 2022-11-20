import 'package:mongo_dart/src/parameters/write_concern.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_options.dart';

class ReplaceOneOptions extends UpdateOptions {
  ReplaceOneOptions(
      {WriteConcern? writeConcern,
      bool? bypassDocumentValidation,
      String? comment})
      : super(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation,
            comment: comment);
}
