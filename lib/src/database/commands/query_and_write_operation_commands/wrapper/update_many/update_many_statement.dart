import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_statement.dart';

class UpdateManyStatement extends UpdateStatement {
  UpdateManyStatement(super.q, super.u,
      {super.upsert,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super(multi: true);
}
