import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/commands/parameters/read_concern.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class FindOptions {
  /// The number of documents to return in the first batch. Defaults to **101**.
  /// A batchSize of 0 means that the cursor will be established,
  /// but no documents will be returned in the first batch.
  /// Unlike the previous wire protocol version, a batchSize of 1 for the find
  /// command does not close the cursor
  final int batchSize;

  /// Determines whether to close the cursor after the first batch.
  /// Defaults to false.
  final bool singleBatch;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the
  /// following locations:
  /// * mongod log messages, in the attr.command.cursor.comment field.
  /// * Database profiler output, in the command.comment field.
  /// * currentOp output, in the command.comment field.
  /// A comment can be only of type String unlike MongoDb that allows
  /// any valid BSON type since 4.4.
  /// **Note**
  /// Any comment set on a find command is inherited by any subsequent
  /// getMore commands run on the find cursor.
  final String comment;

  /// The cumulative time limit in milliseconds for processing operations on
  /// the cursor. MongoDB aborts the operation at the earliest following
  /// interrupt point.
  /// **Tip**
  /// When specifying linearizable read concern, always use maxTimeMS in case
  /// a majority of data bearing members are unavailable. maxTimeMS ensures
  /// that the operation does not block indefinitely and instead ensures that
  /// the operation returns an error if the read concern cannot be fulfilled.
  final int maxTimeMS;

  /// Starting in MongoDB 3.6, the readConcern option has the following syntax:
  /// readConcern: { level: <value> }
  /// Possible read concern levels are:
  /// * "local". This is the default read concern level for read operations
  /// against primary and read operations against secondaries when associated
  /// with causally consistent sessions.
  /// * "available". This is the default for reads against secondaries when
  ///    when not associated with causally consistent sessions. The query returns the instance’s most recent data.
  /// * "majority". Available for replica sets that use WiredTiger storage engine.
  /// * "linearizable". Available for read operations on the primary only.
  /// For more formation on the read concern levels, see [Read Concern Levels](https://docs.mongodb.com/manual/reference/read-concern/#read-concern-levels).
  /// The getMore command uses the readConcern level specified in the
  /// originating find command.
  final ReadConcern readConcern;

  /// The exclusive upper bound for a specific index. See cursor.max()
  /// for details.
  /// Starting in MongoDB 4.2, to use the max field, the command must also
  /// use hint unless the specified filter is an equality condition on the
  /// _id field { _id: <value> }.
  final Map<String, Object> max;

  /// The inclusive lower bound for a specific index. See cursor.min()
  /// for details.
  /// Starting in MongoDB 4.2, to use the min field, the command must also
  /// use hint unless the specified filter is an equality condition on the
  /// _id field { _id: <value> }.
  final Map<String, Object> min;

  /// If true, returns only the index keys in the resulting documents.
  /// Default value is false. If returnKey is true and the find command does
  /// not use an index, the returned documents will be empty.
  final bool returnKey;

  /// Determines whether to return the record identifier for each document.
  /// If true, adds a field $recordId to the returned documents.
  final bool showRecordId;

  /// Returns a tailable cursor for a capped collections
  final bool tailable;

  /// Use in conjunction with the tailable option to block a getMore command
  /// on the cursor temporarily if at the end of data rather than returning
  /// no data. After a timeout period, find returns as normal.
  final bool awaitData;
  @Deprecated('Deprecated since version 4.4')

  /// An internal command for replaying a replica set’s oplog.
  final bool oplogReplay;

  /// Prevents the server from timing out idle cursors after an inactivity
  /// period (10 minutes).
  final bool noCursorTimeout;

  /// For queries against a sharded collection, allows the command
  /// (or subsequent getMore commands) to return partial results,
  /// rather than an error, if one or more queried shards are unavailable.
  /// Starting in MongoDB 4.4, if find (or subsequent getMore commands)
  /// returns partial results due to the unavailability of the queried shard(s),
  /// the output includes a partialResultsReturned indicator field.
  /// If the queried shards are initially available for the find command but
  /// one or more shards become unavailable in subsequent getMore commands,
  /// only the getMore commands run when a queried shard or shards are
  /// unavailable include the partialResultsReturned flag in the output.
  final bool allowPartialResult;

  /// Specifies the [collation] to use for the operation.
  /// Collation allows users to specify language-specific rules for string
  /// comparison, such as rules for lettercase and accent marks.
  /// [See Collation document](https://docs.mongodb.com/manual/reference/collation/#collation-document-fields)
  /// @Since(3.4)
  final CollationOptions collation;

  /// Use allowDiskUse to allow MongoDB to use temporary files on disk to
  /// store data exceeding the 100 megabyte memory limit while processing a
  /// non-indexed (“blocking”) sort operation. If MongoDB requires using more
  /// than 100 megabytes of memory for a blocking sort operation,
  /// MongoDB returns an error unless the query specifies allowDiskUse.
  /// See Sort and Index Use for more information on blocking sort operations.
  /// allowDiskUse has no effect if MongoDB can satisfy the specified sort
  /// using an index, or if the blocking sort requires less than 100 megabytes
  /// of memory.
  /// For more complete documentation on allowDiskUse,
  /// see cursor.allowDiskUse().
  /// For more information on memory restrictions for large blocking sorts,
  /// see [Sort and Index Use](https://docs.mongodb.com/manual/reference/method/cursor.sort/#sort-index-use).
  /// @Since(4.4)
  final bool allowDiskUse;

  FindOptions(
      {this.batchSize,
      this.singleBatch,
      this.comment,
      this.maxTimeMS,
      this.readConcern,
      this.max,
      this.min,
      this.returnKey,
      this.showRecordId,
      this.tailable,
      this.oplogReplay,
      this.noCursorTimeout,
      this.awaitData,
      this.allowPartialResult,
      this.collation,
      this.allowDiskUse}) {
    if (batchSize != null && batchSize < 0) {
      throw MongoDartError('Batch size parameter must be a non negative value');
    }
    if (maxTimeMS != null && maxTimeMS < 1) {
      throw MongoDartError('MaxTimeMS parameter must be a positive value');
    }
  }

  Map<String, Object> get options => <String, Object>{
        if (batchSize != null) keyBatchSize: batchSize,
        if (singleBatch != null) keySingleBatch: singleBatch,
        if (comment != null) keyComment: comment,
        if (maxTimeMS != null) keyMaxTimeMS: maxTimeMS,
        if (readConcern != null) keyReadConcern: readConcern.toMap(),
        if (max != null) keyMax: max,
        if (min != null) keyMin: min,
        if (returnKey != null) keyReturnKey: returnKey,
        if (showRecordId != null) keyShowRecordId: showRecordId,
        if (tailable != null) keyTailable: tailable,
        if (oplogReplay != null) keyOplogReplay: oplogReplay,
        if (noCursorTimeout != null) keyNoCursorTimeout: noCursorTimeout,
        if (awaitData != null) keyAwaitData: awaitData,
        if (allowPartialResult != null)
          keyAllowPartialResult: allowPartialResult,
        if (collation != null) keyCollation: collation.options,
        if (allowDiskUse != null) keyAllowDiskUse: allowDiskUse,
      };
}
