import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src/command/parameters/collation_options.dart';

class UpdateManyStatement extends UpdateStatement {
  UpdateManyStatement(Map<String, Object?> q, Object u,
      {bool? upsert,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument})
      : super(q, u,
            upsert: upsert,
            multi: true,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint,
            hintDocument: hintDocument);
}
