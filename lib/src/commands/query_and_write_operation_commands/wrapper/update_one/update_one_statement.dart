import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src_old/database/utils/update_document_check.dart';

import '../../../../core/error/mongo_dart_error.dart';

class UpdateOneStatement extends UpdateStatement {
  UpdateOneStatement(Map<String, Object?> q, Object u,
      {bool? upsert,
      CollationOptions? collation,
      List<dynamic>? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument})
      : super(q, u,
            upsert: upsert,
            multi: false,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint,
            hintDocument: hintDocument) {
    if (u is Map<String, dynamic> && !containsOnlyUpdateOperators(u)) {
      throw MongoDartError('Invalid document in UpdateOneStatement. '
          'The document is either null or contains invalid update operators');
    }
  }
}
