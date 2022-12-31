import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/update_many/base/update_many_specs.dart';

import '../open/update_many_statement_open.dart';
import '../v1/update_many_statement_v1.dart';

abstract class UpdateManyStatement extends UpdateStatement {
  @protected
  UpdateManyStatement.protected(QueryFilter q, Object u,
      {bool? upsert,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument})
      : super.protected(q, UpdateManySpecs(u).specs,
            upsert: upsert,
            multi: true,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint,
            hintDocument: hintDocument);

  factory UpdateManyStatement(QueryFilter q, Object u,
      {ServerApi? serverApi,
      bool? upsert,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return UpdateManyStatementV1(q, u,
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint,
          hintDocument: hintDocument);
    }
    return UpdateManyStatementOpen(q, u,
        upsert: upsert,
        collation: collation,
        arrayFilters: arrayFilters,
        hint: hint,
        hintDocument: hintDocument);
  }

  UpdateManyStatementOpen get toUpdateManyOpen =>
      this is UpdateManyStatementOpen
          ? this as UpdateManyStatementOpen
          : UpdateManyStatementOpen(q, u as UpdateDocument,
              upsert: upsert,
              collation: collation,
              arrayFilters: arrayFilters,
              hint: hint,
              hintDocument: hintDocument);

  UpdateManyStatementV1 get toUpdateManyV1 => this is UpdateManyStatementV1
      ? this as UpdateManyStatementV1
      : UpdateManyStatementV1(q, u as UpdateDocument,
          upsert: upsert,
          collation: collation,
          arrayFilters: arrayFilters,
          hint: hint,
          hintDocument: hintDocument);
}
