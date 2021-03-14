import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class UpdateOptions {
  /// A document expressing the [write concern](https://docs.mongodb.com/manual/reference/write-concern/).
  /// of the update operation. Omit to use the default write concern.
  ///
  /// Do not explicitly set the write concern for the operation if run
  /// in a transaction. To use write concern with transactions,
  /// see [Transactions and Write Concern.](https://docs.mongodb.com/manual/core/transactions/#transactions-write-concern)
  WriteConcern writeConcern;

  /// Enables update to bypass document validation during the operation.
  /// This lets you update documents that do not meet the validation
  /// requirements.
  ///
  /// New in version 3.2.
  bool bypassDocumentValidation = false;

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

  UpdateOptions(
      {this.writeConcern, this.bypassDocumentValidation, this.comment}) {
    bypassDocumentValidation ??= false;
  }

  Map<String, Object> getOptions(Db db) => <String, Object>{
        if (bypassDocumentValidation)
          keyBypassDocumentValidation: bypassDocumentValidation,
        if (writeConcern != null)
          keyWriteConcern:
              writeConcern.asMap(db.masterConnection?.serverStatus),
        if (comment != null) keyComment: comment,
      };
}
