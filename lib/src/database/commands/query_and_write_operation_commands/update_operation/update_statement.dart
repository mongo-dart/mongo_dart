import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class UpdateStatement {
  UpdateStatement(this.q, this.u,
      {this.upsert,
      this.multi,
      this.collation,
      this.arrayFilters,
      this.hint,
      this.hintDocument}) {
    if (q == null) {
      throw MongoDartError(
          'A filter must be specified (empty Map if update all documents)');
    }
    if (u == null) {
      throw MongoDartError('The update document must be specified');
    }
    if (arrayFilters != null && arrayFilters is! List && arrayFilters is! Map) {
      throw MongoDartError(
          'The arrayFilters parameter must be either a List or a Map');
    }
    upsert ??= false;
    multi ??= false;
  }

  /// The query that matches documents to update.
  /// Use the same query selectors as used in the find() method.
  Map<String, Object> q;

  /// The modifications to apply.
  ///
  /// The value can be either:
  /// - A Map that contains update operator expressions,
  /// - A replacement document with only <field1>: <value1> pairs, or
  /// - Starting in MongoDB 4.2, an aggregation pipeline.
  ///   * `$addFields` and its alias `$set`
  ///   * `$project` and its alias `$unset`
  ///   * `$replaceRoot` and its alias `$replaceWith`.
  Object u;

  /// If true, perform an insert if no documents match the query.
  /// If both upsert and multi are true and no documents match the query,
  /// the update operation inserts only a single document.
  bool upsert = false;

  /// If true, updates all documents that meet the query criteria.
  /// If false, limit the update to one document that meet the query criteria.
  /// Defaults to false.
  bool multi = false;

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
  /// You cannot specify multiple collations for an operation. For example,
  /// you cannot specify different collations per field, or if performing a
  /// find with a sort, you cannot use one collation for the find and another
  /// for the sort.
  ///
  /// New in version 3.4.
  CollationOptions collation;

  /// An array of filter documents that determine which array elements to
  /// modify for an update operation on an array field.
  ///
  /// In the update document, use the `$[<identifier>]` filtered positional
  /// operator to define an identifier, which you then reference in the
  /// array filter documents. You cannot have an array filter document
  /// for an identifier if the identifier is not included in the
  /// update document.
  ///
  /// **NOTE**
  /// The `<identifier>` must begin with a lowercase letter and contain
  /// only alphanumeric characters.
  ///
  /// You can include the same identifier multiple times in the
  /// update document; however, for each distinct identifier **($[identifier])**
  /// in the update document, you must specify **exactly one** corresponding array
  /// filter document. That is, you cannot specify multiple array filter
  /// documents for the same identifier. For example, if the update statement
  /// includes the identifier x (possibly multiple times),
  /// you cannot specify the following for **arrayFilters** that includes 2
  /// separate filter documents for x:
  /// ```dart
  /// // INVALID
  /// [
  ///   { "x.a": { $gt: 85 } },
  ///   { "x.b": { $gt: 80 } }
  /// ]
  /// ```
  /// However, you can specify compound conditions on the same identifier
  /// in a single filter document, such as in the following examples:
  /// ```dart
  /// // Example 1
  /// [
  ///   { $or: [{"x.a": {$gt: 85}}, {"x.b": {$gt: 80}}] }
  /// ]
  ///
  /// // Example 2
  /// [
  ///   { $and: [{"x.a": {$gt: 85}}, {"x.b": {$gt: 80}}] }
  /// ]
  /// // Example 3
  /// [
  ///   { "x.a": { $gt: 85 }, "x.b": { $gt: 80 } }
  /// ]
  /// ```
  /// For examples, see [Specify arrayFilters for Array Update Operations](https://docs.mongodb.com/manual/reference/command/update/#update-command-arrayfilters).
  ///
  /// New in version 3.6.
  ///
  List arrayFilters;

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
  String hint;
  Map<String, Object> hintDocument;

  Map<String, Object> toMap() {
    return <String, Object>{
      keyQ: q,
      keyU: u,
      if (upsert) keyUpsert: upsert,
      if (multi) keyMulti: multi,
      if (collation != null) keyCollation: collation.options,
      if (arrayFilters != null) keyArrayFilters: arrayFilters,
      if (hint != null)
        keyHint: hint
      else if (hintDocument != null)
        keyHint: hintDocument,
    };
  }
}
