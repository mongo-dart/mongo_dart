import 'package:mongo_dart/src/command/command.dart';
import 'package:mongo_dart/src/utils/query_union.dart';

import '../../../update_operation/base/update_union.dart';

class UpdateOneStatementV1 extends UpdateOneStatement {
  UpdateOneStatementV1(QueryUnion q, UpdateUnion u,
      {super.upsert,
      super.collation,
      super.arrayFilters,
      super.hint,
      super.hintDocument})
      : super.protected(q, u);
}
