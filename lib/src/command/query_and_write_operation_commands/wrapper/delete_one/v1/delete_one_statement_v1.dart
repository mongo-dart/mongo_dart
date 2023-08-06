import 'package:mongo_dart/src/command/command.dart';

import '../../../../../unions/query_union.dart';

class DeleteOneStatementV1 extends DeleteOneStatement {
  DeleteOneStatementV1(QueryUnion filter, {super.collation, super.hint})
      : super.protected(filter);
}
