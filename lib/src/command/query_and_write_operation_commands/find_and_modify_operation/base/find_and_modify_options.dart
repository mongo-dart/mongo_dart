import 'package:mongo_dart/mongo_dart.dart';

import '../../../base/operation_base.dart';
import '../open/find_and_modify_options_open.dart';
import '../v1/find_and_modify_options_v1.dart';

class FindAndModifyOptions {
  FindAndModifyOptions.protected(
      {bool? bypassDocumentValidation,
      this.writeConcern,
      this.maxTimeMS,
      this.collation,
      this.comment})
      : bypassDocumentValidation = bypassDocumentValidation ?? false {
    if (maxTimeMS != null && maxTimeMS! < 1) {
      throw MongoDartError('MaxTimeMS parameter must be a positive value');
    }
  }

  factory FindAndModifyOptions(
      {ServerApi? serverApi,
      bool? bypassDocumentValidation,
      WriteConcern? writeConcern,
      int? maxTimeMS,
      CollationOptions? collation,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return FindAndModifyOptionsV1(
          bypassDocumentValidation: bypassDocumentValidation,
          writeConcern: writeConcern,
          maxTimeMS: maxTimeMS,
          collation: collation,
          comment: comment);
    }
    return FindAndModifyOptionsOpen(
        bypassDocumentValidation: bypassDocumentValidation,
        writeConcern: writeConcern,
        maxTimeMS: maxTimeMS,
        collation: collation,
        comment: comment);
  }

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
  WriteConcern? writeConcern;

  /// Specifies a time limit in milliseconds for processing the operation.
  final int? maxTimeMS;

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
  final CollationOptions? collation;

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
  final String? comment;

  FindAndModifyOptionsOpen get toFindAndModifyOpen =>
      this is FindAndModifyOptionsOpen
          ? this as FindAndModifyOptionsOpen
          : FindAndModifyOptionsOpen(
              bypassDocumentValidation: bypassDocumentValidation,
              writeConcern: writeConcern,
              maxTimeMS: maxTimeMS,
              collation: collation,
              comment: comment);

  FindAndModifyOptionsV1 get toFindAndModifyV1 => this is FindAndModifyOptionsV1
      ? this as FindAndModifyOptionsV1
      : FindAndModifyOptionsV1(
          bypassDocumentValidation: bypassDocumentValidation,
          writeConcern: writeConcern,
          maxTimeMS: maxTimeMS,
          collation: collation,
          comment: comment);

  Options getOptions(MongoDatabase db) => <String, dynamic>{
        if (bypassDocumentValidation)
          keyBypassDocumentValidation: bypassDocumentValidation,
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(db.server.serverStatus),
        if (maxTimeMS != null) keyMaxTimeMS: maxTimeMS!,
        if (collation != null) keyCollation: collation!.options,
        if (comment != null) keyComment: comment!,
      };
}
