import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/delete_statement.dart';

import '../open/delete_one_statement_open.dart';
import '../v1/delete_one_statement_v1.dart';

abstract class DeleteOneStatement extends DeleteStatement {
  @protected
  DeleteOneStatement.protected(QueryFilter filter,
      {CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument})
      : super(filter,
            collation: collation,
            hint: hint,
            hintDocument: hintDocument,
            limit: 1);

  factory DeleteOneStatement(QueryFilter filter,
      {ServerApi? serverApi,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteOneStatementV1(filter,
          collation: collation, hint: hint, hintDocument: hintDocument);
    }
    return DeleteOneStatementOpen(filter,
        collation: collation, hint: hint, hintDocument: hintDocument);
  }

  DeleteOneStatementOpen get toDeleteOneOpen => this is DeleteOneStatementOpen
      ? this as DeleteOneStatementOpen
      : DeleteOneStatementOpen(filter,
          collation: collation, hint: hint, hintDocument: hintDocument);

  DeleteOneStatementV1 get toDeleteOneV1 => this is DeleteOneStatementV1
      ? this as DeleteOneStatementV1
      : DeleteOneStatementV1(filter,
          collation: collation, hint: hint, hintDocument: hintDocument);
}
