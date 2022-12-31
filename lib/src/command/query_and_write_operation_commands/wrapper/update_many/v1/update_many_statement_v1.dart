import 'package:mongo_dart/src/command/command.dart';

import '../../../../../database/database.dart';

class UpdateManyStatementV1 extends UpdateManyStatement {
  UpdateManyStatementV1(QueryFilter q, Object u,
      {super.upsert,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super.protected(q, u);
}
