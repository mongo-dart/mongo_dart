import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/unions/hint_union.dart';
import '../../../../../unions/query_union.dart';
import '../../../update_operation/base/update_union.dart';
import '../open/update_one_statement_open.dart';
import '../v1/update_one_statement_v1.dart';

abstract class UpdateOneStatement extends UpdateStatement {
  @protected
  UpdateOneStatement.protected(QueryUnion q, UpdateUnion u,
      {super.upsert, super.collation, super.arrayFilters, super.hint})
      : super.protected(
          q,
          u,
          multi: false,
        ) {
    if (!u.specs.containsOnlyUpdateOperators) {
      throw MongoDartError('Invalid document in UpdateOneStatement. '
          'The document is either null or contains invalid update operators');
    }
  }

  factory UpdateOneStatement(QueryUnion q, UpdateUnion u,
      {ServerApi? serverApi,
      bool? upsert,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      HintUnion? hint}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return UpdateOneStatementV1(q, u,
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint);
    }
    return UpdateOneStatementOpen(q, u,
        upsert: upsert,
        collation: collation,
        arrayFilters: arrayFilters,
        hint: hint);
  }

  UpdateOneStatementOpen get toUpdateOneOpen => this is UpdateOneStatementOpen
      ? this as UpdateOneStatementOpen
      : UpdateOneStatementOpen(QueryUnion(q), UpdateUnion(u),
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint);

  UpdateOneStatementV1 get toUpdateOneV1 => this is UpdateOneStatementV1
      ? this as UpdateOneStatementV1
      : UpdateOneStatementV1(QueryUnion(q), UpdateUnion(u),
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint);
}
