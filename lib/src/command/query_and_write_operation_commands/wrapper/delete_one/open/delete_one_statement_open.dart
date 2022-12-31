import 'package:mongo_dart/src/command/command.dart';

import '../../../../../database/database.dart';

class DeleteOneStatementOpen extends DeleteOneStatement {
  DeleteOneStatementOpen(QueryFilter filter,
      {super.collation, super.hint, super.hintDocument})
      : super.protected(filter);
}
