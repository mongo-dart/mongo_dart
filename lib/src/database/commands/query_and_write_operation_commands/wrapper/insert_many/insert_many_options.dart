import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/insert_operation/insert_options.dart';

class InsertManyOptions extends InsertOptions {
  InsertManyOptions(
      {super.writeConcern,
      super.ordered = null,
      super.bypassDocumentValidation = null});
}
