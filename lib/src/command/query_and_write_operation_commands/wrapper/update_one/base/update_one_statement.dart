import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../../../utils/query_union.dart';
import '../../../update_operation/base/update_union.dart';
import '../open/update_one_statement_open.dart';
import '../v1/update_one_statement_v1.dart';

abstract class UpdateOneStatement extends UpdateStatement {
  @protected
  UpdateOneStatement.protected(QueryUnion q, UpdateUnion u,
      {bool? upsert,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument})
      : super.protected(q, u,
            upsert: upsert,
            multi: false,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint,
            hintDocument: hintDocument) {
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
      String? hint,
      Map<String, Object>? hintDocument}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return UpdateOneStatementV1(q, u,
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint,
          hintDocument: hintDocument);
    }
    return UpdateOneStatementOpen(q, u,
        upsert: upsert,
        collation: collation,
        arrayFilters: arrayFilters,
        hint: hint,
        hintDocument: hintDocument);
  }

  UpdateOneStatementOpen get toUpdateOneOpen => this is UpdateOneStatementOpen
      ? this as UpdateOneStatementOpen
      : UpdateOneStatementOpen(QueryUnion(q), UpdateUnion(u),
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint,
          hintDocument: hintDocument);

  UpdateOneStatementV1 get toUpdateOneV1 => this is UpdateOneStatementV1
      ? this as UpdateOneStatementV1
      : UpdateOneStatementV1(QueryUnion(q), UpdateUnion(u),
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint,
          hintDocument: hintDocument);
}
