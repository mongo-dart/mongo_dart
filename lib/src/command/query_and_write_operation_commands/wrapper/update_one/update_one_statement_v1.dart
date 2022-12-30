import 'package:mongo_dart/src/command/command.dart';

import '../../../../database/database.dart';

class UpdateOneStatementV1 extends UpdateOneStatement {
  UpdateOneStatementV1(QueryFilter q, UpdateSpecs u,
      {super.upsert,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super.protected(q, u);
}
