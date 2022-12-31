import 'package:mongo_dart/src/command/command.dart';

class DeleteManyStatementOpen extends DeleteManyStatement {
  DeleteManyStatementOpen(super.filter,
      {super.collation, super.hint, super.hintDocument})
      : super.protected();
}
