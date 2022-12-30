import 'package:mongo_dart/src/command/command.dart';

import '../../../../database/database.dart';

class UpdateManyStatementOpen extends UpdateManyStatement {
  UpdateManyStatementOpen(QueryFilter q, UpdateSpecs u,
      {super.upsert,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super.protected(q, u);
}
