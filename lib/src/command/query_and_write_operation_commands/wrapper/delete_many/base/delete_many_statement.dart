import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/base/delete_statement.dart';
import 'package:mongo_dart/src/utils/hint_union.dart';

import '../../../../../utils/query_union.dart';
import '../open/delete_many_statement_open.dart';
import '../v1/delete_many_statement_v1.dart';

abstract class DeleteManyStatement extends DeleteStatement {
  @protected
  DeleteManyStatement.protected(QueryUnion filter,
      {super.collation, super.hint})
      : super.protected(filter, limit: 0);

  factory DeleteManyStatement(QueryUnion filter,
      {ServerApi? serverApi, CollationOptions? collation, HintUnion? hint}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteManyStatementV1(filter, collation: collation, hint: hint);
    }
    return DeleteManyStatementOpen(filter, collation: collation, hint: hint);
  }

  DeleteManyStatementOpen get toDeleteManyOpen =>
      this is DeleteManyStatementOpen
          ? this as DeleteManyStatementOpen
          : DeleteManyStatementOpen(QueryUnion(filter),
              collation: collation, hint: hint);

  DeleteManyStatementV1 get toDeleteManyV1 => this is DeleteManyStatementV1
      ? this as DeleteManyStatementV1
      : DeleteManyStatementV1(QueryUnion(filter),
          collation: collation, hint: hint);
}
