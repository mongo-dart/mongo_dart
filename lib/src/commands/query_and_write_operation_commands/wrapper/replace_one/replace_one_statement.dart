import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src_old/database/utils/update_document_check.dart';

import '../../../../core/error/mongo_dart_error.dart';

class ReplaceOneStatement extends UpdateStatement {
  ReplaceOneStatement(Map<String, Object?> q, Map<String, dynamic> u,
      {bool? upsert,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument})
      : super(q, u,
            upsert: upsert,
            multi: false,
            collation: collation,
            hint: hint,
            hintDocument: hintDocument) {
    if (!isPureDocument(u)) {
      throw MongoDartError('Invalid document in ReplaceOneStatement. '
          'The document is either null or contains update operators');
    }
  }
}
