import 'package:mongo_dart/src/command/parameters/write_concern.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_options.dart';

class InsertOneOptions extends InsertOptions {
  InsertOneOptions({WriteConcern? writeConcern, bool? bypassDocumentValidation})
      : super(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation);
}