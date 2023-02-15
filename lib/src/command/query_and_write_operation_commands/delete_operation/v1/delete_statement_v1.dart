import '../base/delete_statement.dart';

class DeleteStatementV1 extends DeleteStatement {
  DeleteStatementV1(super.filter, {super.collation, super.hint, super.limit})
      : super.protected();
}
