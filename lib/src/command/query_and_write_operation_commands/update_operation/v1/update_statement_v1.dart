import 'package:mongo_dart/src/command/command.dart';

class UpdateStatementV1 extends UpdateStatement {
  UpdateStatementV1(super.q, super.u,
      {super.upsert,
      super.multi,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super.protected();
}
