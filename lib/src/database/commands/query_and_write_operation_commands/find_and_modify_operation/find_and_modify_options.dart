import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class FindAndModifyOptions {
  /// Enables findAndModify to bypass document validation during the operation.
  /// This lets you update documents that do not meet the validation
  /// requirements.
  ///
  /// New in version 3.2.
  bool bypassDocumentValidation = false;

  /// A document expressing the [write concern](https://docs.mongodb.com/manual/reference/write-concern/). Omit to use the
  /// default write concern.
  ///
  /// Do not explicitly set the write concern for the operation if run
  /// in a transaction. To use write concern with transactions,
  /// see [Transactions and Write Concern.](https://docs.mongodb.com/manual/core/transactions/#transactions-write-concern)
  ///
  /// New in version 3.2.
  WriteConcern writeConcern;

  /// Specifies a time limit in milliseconds for processing the operation.
  final int maxTimeMS;

  /// Specifies the collation to use for the operation.
  ///
  /// Collation allows users to specify language-specific rules for string
  /// comparison, such as rules for lettercase and accent marks.
  ///
  /// When specifying collation, the locale field is mandatory;
  /// all other collation fields are optional. For descriptions of the fields,
  /// see [Collation Document](https://docs.mongodb.com/manual/reference/collation/#collation-document-fields)
  ///
  /// If the collation is unspecified but the collection has a default
  /// collation (see db.createCollection()), the operation uses the collation
  /// specified for the collection.
  ///
  /// If no collation is specified for the collection or for the operations,
  /// MongoDB uses the simple binary comparison used in prior versions
  /// for string comparisons.
  ///
  /// You cannot specify multiple collations for an operation.
  /// For example, you cannot specify different collations per field,
  /// or if performing a find with a sort, you cannot use one collation
  /// for the find and another for the sort.
  ///
  /// New in version 3.4.
  final CollationOptions collation;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the
  /// following locations:
  /// * mongod log messages, in the attr.command.cursor.comment field.
  /// * Database profiler output, in the command.comment field.
  /// * currentOp output, in the command.comment field.
  ///
  /// A comment can be only of type String unlike MongoDb that allows
  /// any valid BSON type
  ///
  /// New in version 4.4.
  final String comment;

  FindAndModifyOptions(
      {this.bypassDocumentValidation,
      this.writeConcern,
      this.maxTimeMS,
      this.collation,
      this.comment}) {
    bypassDocumentValidation ??= false;

    if (maxTimeMS != null && maxTimeMS < 1) {
      throw MongoDartError('MaxTimeMS parameter must be a positive value');
    }
  }

  Map<String, Object> getOptions(Db db) => <String, Object>{
        if (bypassDocumentValidation)
          keyBypassDocumentValidation: bypassDocumentValidation,
        if (writeConcern != null)
          keyWriteConcern:
              writeConcern.asMap(db.masterConnection?.serverStatus),
        if (maxTimeMS != null) keyMaxTimeMS: maxTimeMS,
        if (collation != null) keyCollation: collation.options,
        if (comment != null) keyComment: comment,
      };
}
