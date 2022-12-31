import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_statement.dart';

import '../open/delete_many_statement_open.dart';
import '../v1/delete_many_statement_v1.dart';

abstract class DeleteManyStatement extends DeleteStatement {
  @protected
  DeleteManyStatement.protected(QueryFilter filter,
      {CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument})
      : super.protected(filter,
            collation: collation,
            hint: hint,
            hintDocument: hintDocument,
            limit: 0);

  factory DeleteManyStatement(QueryFilter filter,
      {ServerApi? serverApi,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteManyStatementV1(filter,
          collation: collation, hint: hint, hintDocument: hintDocument);
    }
    return DeleteManyStatementOpen(filter,
        collation: collation, hint: hint, hintDocument: hintDocument);
  }

  DeleteManyStatementOpen get toDeleteManyOpen =>
      this is DeleteManyStatementOpen
          ? this as DeleteManyStatementOpen
          : DeleteManyStatementOpen(filter,
              collation: collation, hint: hint, hintDocument: hintDocument);

  DeleteManyStatementV1 get toDeleteManyV1 => this is DeleteManyStatementV1
      ? this as DeleteManyStatementV1
      : DeleteManyStatementV1(filter,
          collation: collation, hint: hint, hintDocument: hintDocument);
}
