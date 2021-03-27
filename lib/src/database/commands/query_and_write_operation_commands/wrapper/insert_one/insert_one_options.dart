import 'package:mongo_dart/mongo_dart.dart' show WriteConcern;
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/insert_operation/insert_options.dart';

class InsertOneOptions extends InsertOptions {
  InsertOneOptions({WriteConcern? writeConcern, bool? bypassDocumentValidation})
      : super(
            writeConcern: writeConcern,
            bypassDocumentValidation: bypassDocumentValidation);
}
