import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show
        MongoDatabase,
        ServerApi,
        ServerApiVersion,
        WriteConcern,
        keyBypassDocumentValidation,
        keyComment,
        keyWriteConcern;

import '../../../base/operation_base.dart';
import '../update_options_open.dart';
import '../update_options_v1.dart';

abstract class UpdateOptions {
  @protected
  UpdateOptions.protected(
      {this.writeConcern, bool? bypassDocumentValidation, this.comment})
      : bypassDocumentValidation = bypassDocumentValidation ?? false;

  factory UpdateOptions(
      {ServerApi? serverApi,
      WriteConcern? writeConcern,
      bool? bypassDocumentValidation = false,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return UpdateOptionsV1(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);
    }
    return UpdateOptionsOpen(
        writeConcern: writeConcern,
        bypassDocumentValidation: bypassDocumentValidation,
        comment: comment);
  }

  /// A document expressing the [write concern](https://docs.mongodb.com/manual/reference/write-concern/).
  /// of the update operation. Omit to use the default write concern.
  ///
  /// Do not explicitly set the write concern for the operation if run
  /// in a transaction. To use write concern with transactions,
  /// see [Transactions and Write Concern.](https://docs.mongodb.com/manual/core/transactions/#transactions-write-concern)
  WriteConcern? writeConcern;

  /// Enables update to bypass document validation during the operation.
  /// This lets you update documents that do not meet the validation
  /// requirements.
  ///
  /// New in version 3.2.
  bool bypassDocumentValidation;

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

  UpdateOptionsOpen get toOpen => this is UpdateOptionsOpen
      ? this as UpdateOptionsOpen
      : UpdateOptionsOpen(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);

  UpdateOptionsV1 get toV1 => this is UpdateOptionsV1
      ? this as UpdateOptionsV1
      : UpdateOptionsV1(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation,
          comment: comment);

  Options getOptions(MongoDatabase db) => <String, dynamic>{
        if (bypassDocumentValidation)
          keyBypassDocumentValidation: bypassDocumentValidation,
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(db.server.serverStatus),
        if (comment != null) keyComment: comment!,
      };
}
