import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/operation/commands/aggreagation_commands/aggregate/aggregate_options.dart';
import 'package:mongo_dart/src/database/operation/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Parameters for the ChangeStream Operation
///
/// Please, note that even if the resume parameters are present,
/// no atomatic resume logic is applied (at least in this driver version).
class ChangeStreamOptions extends AggregateOptions {
  ChangeStreamOptions(
      {this.resumeAfter,
      this.startAfter,
      this.fullDocument,
      this.maxAwaitTimeMS,
      this.startAtOperationTime,
      bool bypassDocumentValidation,
      bool allowDiskUse,
      CollationOptions collation,
      String comment})
      : super(
            allowDiskUse: allowDiskUse,
            // It make sense to pass a timeout for an operation that never ends?
            //maxTimeMS: maxTimeMS,
            bypassDocumentValidation: bypassDocumentValidation,
            // This is not a watch parameters (shell command).
            // I assumed that all operations are made on the primary
            // so it is not needed
            // readConcern: readConcern
            collation: collation,
            // write concern is only for stages $out and $merge that
            // are not allowed in a change stream
            //writeConcern: writeConcern,
            comment: comment);

  /// Directs watch to attempt resuming notifications starting after the
  /// operation specified in the resume token.
  ///
  /// Each change stream event document includes a resume token as the _id
  ///  field. Pass the entire _id field of the change event document that
  /// represents the operation you want to resume after.
  ///
  /// resumeAfter is mutually exclusive with startAfter and startAtOperationTime
  Map<String, Object> resumeAfter;

  /// Directs watch to attempt starting a new change stream after the operation
  /// specified in the resume token. Allows notifications to resume after an
  /// invalidate event.
  ///
  /// Each change stream event document includes a resume token as the _id
  /// field. Pass the entire _id field of the change event document that
  /// represents the operation you want to resume after.
  ///
  /// startAfter is mutually exclusive with resumeAfter and startAtOperationTime
  ///
  /// New in version 4.2.
  Map<String, Object> startAfter;

  /// By default, the change stream returns the delta of those fields modified
  /// by an update operation, instead of the entire updated document.
  ///
  /// Set fullDocument to "updateLookup" to direct changeStream to look up the
  /// most current majority-committed version of the updated document.
  /// The Change Stream returns a fullDocument field with the document lookup
  /// in addition to the updateDescription delta.
  String fullDocument;

  /// The maximum amount of time in milliseconds the server waits for new data
  /// changes to report to the change stream cursor before returning an
  /// empty batch.
  ///
  /// Defaults to 1000 milliseconds.
  int maxAwaitTimeMS;

  /// The starting point for the change stream. If the specified starting
  /// point is in the past, it must be in the time range of the oplog.
  /// To check the time range of the oplog, see rs.printReplicationInfo().
  ///
  /// startAtOperationTime is mutually exclusive with resumeAfter and startAfter
  ///
  /// New in version 4.0.
  Timestamp startAtOperationTime;

  /// These options mut be passed to the $changeStream key in the aggregate
  /// command
  Map<String, Object> changeStreamSpecificOptions() => <String, Object>{
        if (resumeAfter != null) keyResumeAfter: resumeAfter,
        if (startAfter != null) keyStartAfter: startAfter,
        if (fullDocument != null) keyFullDocument: fullDocument,
        if (maxAwaitTimeMS != null) keyMaxAwaitTimeMS: maxAwaitTimeMS,
        if (startAtOperationTime != null)
          keyStartAtOperationTime: startAtOperationTime,
      };
}
