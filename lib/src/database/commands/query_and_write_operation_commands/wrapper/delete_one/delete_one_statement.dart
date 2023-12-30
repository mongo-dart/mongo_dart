import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/delete_operation/delete_statement.dart';

class DeleteOneStatement extends DeleteStatement {
  DeleteOneStatement(super.filter,
      {super.collation, super.hint, super.hintDocument})
      : super(limit: 1);
}
