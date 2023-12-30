import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_options.dart';

class ReplaceOneOptions extends UpdateOptions {
  ReplaceOneOptions(
      {super.writeConcern, super.bypassDocumentValidation, super.comment});
}
