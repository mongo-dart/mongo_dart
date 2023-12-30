import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_options.dart';

class UpdateManyOptions extends UpdateOptions {
  UpdateManyOptions(
      {super.writeConcern, super.bypassDocumentValidation, super.comment});
}
