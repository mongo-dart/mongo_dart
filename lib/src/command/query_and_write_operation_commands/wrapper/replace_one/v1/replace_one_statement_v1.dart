import 'package:mongo_dart/src/command/command.dart';

import '../../../../../database/database.dart';

class ReplaceOneStatementV1 extends ReplaceOneStatement {
  ReplaceOneStatementV1(QueryFilter q, MongoDocument u,
      {super.upsert, super.collation, super.hint, super.hintDocument})
      : super.protected(q, u);
}
