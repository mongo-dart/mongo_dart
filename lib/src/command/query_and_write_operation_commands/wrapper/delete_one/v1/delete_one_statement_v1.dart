import 'package:mongo_dart/src/command/command.dart';

import '../../../../../database/database.dart';

class DeleteOneStatementV1 extends DeleteOneStatement {
  DeleteOneStatementV1(QueryFilter filter, {super.collation, super.hint})
      : super.protected(filter);
}
