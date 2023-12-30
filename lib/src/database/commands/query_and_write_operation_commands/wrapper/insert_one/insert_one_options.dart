import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/insert_operation/insert_options.dart';

class InsertOneOptions extends InsertOptions {
  InsertOneOptions({super.writeConcern, super.bypassDocumentValidation = null});
}
