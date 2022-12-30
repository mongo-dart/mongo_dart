import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/delete_statement.dart';
import 'package:mongo_dart/src/command/parameters/collation_options.dart';

class DeleteManyStatement extends DeleteStatement {
  DeleteManyStatement(Map<String, dynamic> filter,
      {CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument})
      : super(filter,
            collation: collation,
            hint: hint,
            hintDocument: hintDocument,
            limit: 0);
}
