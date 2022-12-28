import 'package:mongo_dart/src/command/parameters/write_concern.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_options.dart';

class InsertManyOptions extends InsertOptions {
  InsertManyOptions(
      {WriteConcern? writeConcern,
      bool? ordered,
      bool? bypassDocumentValidation})
      : super(
            writeConcern: writeConcern,
            ordered: ordered,
            bypassDocumentValidation: bypassDocumentValidation);
}
