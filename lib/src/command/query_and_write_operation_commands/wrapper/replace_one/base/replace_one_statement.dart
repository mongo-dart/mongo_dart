import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/utils/update_document_check.dart';

import '../replace_one_statement_open.dart';
import '../replace_one_statement_v1.dart';

abstract class ReplaceOneStatement extends UpdateStatement {
  @protected
  ReplaceOneStatement.protected(QueryFilter q, MongoDocument u,
      {bool? upsert,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument})
      : super.protected(q, u,
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

  factory ReplaceOneStatement(QueryFilter q, MongoDocument u,
      {ServerApi? serverApi,
      bool? upsert,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return ReplaceOneStatementV1(q, u,
          upsert: upsert, collation: collation, hint: hint);
    }
    return ReplaceOneStatementOpen(q, u,
        upsert: upsert, collation: collation, hint: hint);
  }

  ReplaceOneStatementOpen get toReplaceOneOpen =>
      this is ReplaceOneStatementOpen
          ? this as ReplaceOneStatementOpen
          : ReplaceOneStatementOpen(q, u as MongoDocument,
              upsert: upsert, collation: collation, hint: hint);

  ReplaceOneStatementV1 get toReplaceOneV1 => this is ReplaceOneStatementV1
      ? this as ReplaceOneStatementV1
      : ReplaceOneStatementV1(q, u as MongoDocument,
          upsert: upsert, collation: collation, hint: hint);
}
