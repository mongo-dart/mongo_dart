import 'package:mongo_dart/src/command/command.dart';
import 'package:mongo_dart/src/utils/query_union.dart';

import '../../../../../database/database.dart';

class UpdateOneStatementV1 extends UpdateOneStatement {
  UpdateOneStatementV1(QueryUnion q, UpdateDocument u,
      {super.upsert,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super.protected(q, u);
}
