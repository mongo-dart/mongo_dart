import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_statement.dart';
import 'package:mongo_dart/src/unions/hint_union.dart';

import '../../../../../unions/query_union.dart';
import '../open/delete_one_statement_open.dart';
import '../v1/delete_one_statement_v1.dart';

abstract class DeleteOneStatement extends DeleteStatement {
  @protected
  DeleteOneStatement.protected(QueryUnion filter, {super.collation, super.hint})
      : super.protected(filter, limit: 1);

  factory DeleteOneStatement(QueryUnion filter,
      {ServerApi? serverApi, CollationOptions? collation, HintUnion? hint}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteOneStatementV1(filter, collation: collation, hint: hint);
    }
    return DeleteOneStatementOpen(filter, collation: collation, hint: hint);
  }

  DeleteOneStatementOpen get toDeleteOneOpen => this is DeleteOneStatementOpen
      ? this as DeleteOneStatementOpen
      : DeleteOneStatementOpen(QueryUnion(filter),
          collation: collation, hint: hint);

  DeleteOneStatementV1 get toDeleteOneV1 => this is DeleteOneStatementV1
      ? this as DeleteOneStatementV1
      : DeleteOneStatementV1(QueryUnion(filter),
          collation: collation, hint: hint);
}
