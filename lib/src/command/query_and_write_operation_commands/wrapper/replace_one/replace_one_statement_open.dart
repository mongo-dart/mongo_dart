import 'package:mongo_dart/src/command/command.dart';

import '../../../../database/database.dart';

class ReplaceOneStatementOpen extends ReplaceOneStatement {
  ReplaceOneStatementOpen(QueryFilter q, MongoDocument u,
      {super.upsert, super.collation, super.hint, super.hintDocument})
      : super.protected(q, u);
}
