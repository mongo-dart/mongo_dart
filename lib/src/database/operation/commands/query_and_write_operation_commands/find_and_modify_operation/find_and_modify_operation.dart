import 'package:mongo_dart/mongo_dart.dart' show DbCollection, MongoDartError;
import 'package:mongo_dart/src/database/operation/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'find_and_modify_options.dart';
import '../../base/command_operation.dart';
import 'find_and_modify_result.dart';

class FindAndModifyOperation extends CommandOperation {
  FindAndModifyOperation(DbCollection collection,
      {this.query,
      this.sort,
      this.remove,
      this.update,
      this.returnNew,
      this.fields,
      this.upsert,
      this.arrayFilters,
      this.hint,
      this.hintDocument,
      FindAndModifyOptions findAndModifyOptions,
      Map<String, Object> rawOptions})
      : super(
            collection.db,
            <String, Object>{
              ...?findAndModifyOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation) {
    if (arrayFilters != null && arrayFilters is! List && arrayFilters is! Map) {
      throw MongoDartError(
          'The arrayFilters parameter must be either a List or a Map');
    }
    remove ??= false;
    returnNew ??= false;
    upsert ??= false;
  }

  /// The selection criteria for the modification. The query field employs
  /// the same query selectors as used in the db.collection.find() method.
  /// Although the query may match multiple documents,
  /// findAndModify will only select one document to modify.
  ///
  /// If unspecified, defaults to an empty document.
  ///
  /// Starting in MongoDB 4.2 (and 4.0.12+, 3.6.14+, and 3.4.23+),
  /// the operation errors if the query argument is not a document.
  Map<String, Object> query;

  /// Determines which document the operation modifies if the query selects
  /// multiple documents. findAndModify modifies the first document
  /// in the sort order specified by this argument.
  ///
  /// Starting in MongoDB 4.2 (and 4.0.12+, 3.6.14+, and 3.4.23+),
  /// the operation errors if the sort argument is not a document.
  ///
  /// In MongoDB, sorts are inherently stable, unless sorting on a field
  /// which contains duplicate values:
  /// - a stable sort is one that returns the same sort order each time
  ///   it is performed
  /// - an unstable sort is one that may return a different sort order
  ///   when performed multiple times
  ///
  /// If a stable sort is desired, include at least one field in your sort
  /// that contains exclusively unique values. The easiest way to guarantee
  /// this is to include the _id field in your sort query.
  ///
  /// See [Sort Stability](https://docs.mongodb.com/manual/reference/method/cursor.sort/#sort-cursor-stable-sorting) for more information.
  Map<String, Object> sort;

  /// Must specify either the remove or the update field. Removes the document
  /// specified in the query field. Set this to true to remove the
  /// selected document . The default is false.
  bool remove = false;

  /// Must specify either the remove or the update field.
  /// Performs an update of the selected document.
  ///
  /// - If passed a document with update operator expressions,
  /// findAndModify performs the specified modification.
  /// - If passed a replacement document { <field1>: <value1>, ...},
  /// the findAndModify performs a replacement.
  /// - starting in MongoDB 4.2, if passed an aggregation pipeline
  /// [ <stage1>, <stage2>, ... ], findAndModify modifies the document
  /// per the pipeline. The pipeline can consist of the following stages:
  ///   * $addFields and its alias $set
  ///   * $project and its alias $unset
  ///   * $replaceRoot and its alias $replaceWith.
  ///
  /// It can be a Map or a List
  Object update;

  /// When true, returns the modified document rather than the original.
  /// The findAndModify method ignores the 'new' option for remove operations.
  /// The default is false.
  ///
  /// Original name `new` renamed in `returnNew` because of the reserved word
  bool returnNew = false;

  /// A subset of fields to return. The fields document specifies an inclusion
  /// of a field with 1, as in: fields: { <field1>: 1, <field2>: 1, ... }.
  /// See [Projection](https://docs.mongodb.com/manual/reference/method/db.collection.find/#find-projection).
  ///
  /// Starting in MongoDB 4.2 (and 4.0.12+, 3.6.14+, and 3.4.23+),
  /// the operation errors if the fields argument is not a document.
  Map<String, dynamic> fields;

  /// Used in conjunction with the update field.
  ///
  /// When true, findAndModify() either:
  /// - Creates a new document if no documents match the query.
  /// For more details see [upsert behavior](https://docs.mongodb.com/manual/reference/method/db.collection.update/#upsert-behavior).
  /// - Updates a single document that matches the query.
  ///
  /// To avoid multiple upserts,
  /// ensure that the query fields are uniquely indexed.
  ///
  /// Defaults to false.
  bool upsert = false;

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
  /// For examples, see [Array Update Operations with arrayFilters](https://docs.mongodb.com/manual/reference/command/findAndModify/#findandmodify-command-arrayfilters).
  ///
  /// **NOTE**
  /// **arrayFilters** is not available for updates that use an
  /// aggregation pipeline.
  ///
  /// New in version 3.6.
  ///
  List arrayFilters;

  /// Optional. Index specification. Specify either the index name
  /// as a string (hint field) or the index key pattern (hintDocument field).
  /// If specified, then the query system will only consider plans
  /// using the hinted index.
  /// **starting in MongoDB 4.2**, with the following exception,
  /// hint is required if the command includes the min and/or max fields;
  /// hint is not required with min and/or max if the filter is an
  /// equality condition on the _id field { _id: <value> }.
  String hint;
  Map<String, Object> hintDocument;

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyFindAndModify: collection.collectionName,
      if (query != null) keyQuery: query,
      if (sort != null) keySort: sort,
      if (remove) keyRemove: remove,
      if (update != null) keyUpdate: update,
      if (returnNew) keyNew: returnNew,
      if (fields != null) keyFields: fields,
      if (upsert) keyUpsert: upsert,
      if (arrayFilters != null) keyArrayFilters: arrayFilters,
      if (hint != null)
        keyHint: hint
      else if (hintDocument != null)
        keyHint: hintDocument,
    };
  }

  Future<FindAndModifyResult> executeDocument() async {
    var result = await super.execute();
    return FindAndModifyResult(result);
  }
}
