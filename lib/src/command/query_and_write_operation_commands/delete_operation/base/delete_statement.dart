import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/utils/hint_union.dart';
import 'package:mongo_dart/src/utils/query_union.dart';

import '../open/delete_statement_open.dart';
import '../v1/delete_statement_v1.dart';

abstract class DeleteStatement {
  @protected
  DeleteStatement.protected(QueryUnion filter,
      {this.collation, this.hint, int? limit})
      : filter = filter.query,
        limit = limit ?? 1;

  factory DeleteStatement(QueryUnion filter,
      {ServerApi? serverApi,
      CollationOptions? collation,
      HintUnion? hint,
      int? limit}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteStatementV1(filter,
          collation: collation, hint: hint, limit: limit);
    }
    return DeleteStatementOpen(filter,
        collation: collation, hint: hint, limit: limit);
  }

  /// Optional. The query predicate. If unspecified, then all documents in the
  /// collection will match the predicate.
  ///
  /// internal document key is "q"
  QueryFilter filter;

  /// The number of matching documents to delete.
  /// Specify either a 0 to delete all matching documents or 1 to delete a
  /// single document.
  ///
  /// **NOTE**
  ///
  /// At present (4.4) only 0 and 1 can be specified.
  int limit = 1;

  /// Specifies the collation to use for the operation.
  ///
  /// Collation allows users to specify language-specific rules for string
  /// comparison, such as rules for lettercase and accent marks.
  ///
  /// If the collation is unspecified but the collection has a default collation
  /// ([see db.createCollection()](https://docs.mongodb.com/manual/reference/method/db.createCollection/#db.createCollection)),
  /// the operation uses the collation specified for the collection.
  ///
  /// If no collation is specified for the collection or for the operations,
  /// MongoDB uses the simple binary comparison used in prior versions
  /// for string comparisons.
  ///
  /// ou cannot specify multiple collations for an operation. For example,
  /// you cannot specify different collations per field, or if performing a
  /// find with a sort, you cannot use one collation for the find and another
  /// for the sort.
  ///
  /// New in version 3.4.
  CollationOptions? collation;

  /// A document or string that specifies the index to use to support the
  /// query predicate.
  ///
  /// The option can take an index specification document or the index
  /// name string.
  ///
  /// If you specify an index that does not exist, the operation errors.
  ///
  /// For an example, see [Specify hint for Delete Operations](https://docs.mongodb.com/manual/reference/command/delete/#ex-delete-command-hint).
  ///
  /// We define two fields, if set, one exclude the other.
  ///
  /// New in 4.4
  HintUnion? hint;

  DeleteStatementOpen get toOpen => this is DeleteStatementOpen
      ? this as DeleteStatementOpen
      : DeleteStatementOpen(QueryUnion(filter),
          collation: collation, hint: hint, limit: limit);

  DeleteStatementV1 get toV1 => this is DeleteStatementV1
      ? this as DeleteStatementV1
      : DeleteStatementV1(QueryUnion(filter),
          collation: collation, hint: hint, limit: limit);

  Options toMap() {
    return <String, dynamic>{
      keyQ: filter,
      keyLimit: limit,
      if (collation != null) keyCollation: collation!.options,
      if (hint != null && !hint!.isNull) keyHint: hint!.value
    };
  }
}
