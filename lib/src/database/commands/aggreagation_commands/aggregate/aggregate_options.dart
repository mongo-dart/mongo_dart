import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/commands/parameters/read_concern.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class AggregateOptions {
  /// Enables writing to temporary files. When set to true, a
  /// ggregation stages can write data to the _tmp subdirectory in the dbPath
  /// directory.
  ///
  /// Starting in MongoDB 4.2, the profiler log messages and diagnostic log
  /// messages includes a usedDisk indicator if any aggregation stage wrote
  /// data to temporary files due to memory restrictions.
  bool allowDiskUse;

  /// Specifies a time limit in milliseconds for processing operations on a
  /// cursor. If you do not specify a value for maxTimeMS, operations will
  /// not time out. A value of 0 explicitly specifies the default
  /// unbounded behavior.
  ///
  /// MongoDB terminates operations that exceed their allotted time limit
  /// using the same mechanism as db.killOp(). MongoDB only terminates an
  /// operation at one of its designated interrupt points.
  final int maxTimeMS;

  /// Applicable only if you specify the $out or $merge aggregation stages.
  /// Enables aggregate to bypass document validation during the operation.
  /// This lets you insert documents that do not meet the validation requirements.
  ///
  /// New in version 3.2.
  bool bypassDocumentValidation;

  /// Starting in MongoDB 3.6, the readConcern option has the following syntax:
  /// readConcern: { level: <value> }
  /// Possible read concern levels are:
  /// - "local". This is the default read concern level for read operations
  /// against primary and read operations against secondaries when associated
  /// with causally consistent sessions.
  /// - "available". This is the default for reads against secondaries when
  ///    when not associated with causally consistent sessions. The query returns the instance’s most recent data.
  /// - "majority". Available for replica sets that use WiredTiger storage engine.
  /// - "linearizable". Available for read operations on the primary only.
  /// For more formation on the read concern levels, see [Read Concern Levels](https://docs.mongodb.com/manual/reference/read-concern/#read-concern-levels).
  ///
  /// Starting in MongoDB 4.2, the $out stage cannot be used in conjunction
  /// with read concern "linearizable". That is, if you specify "linearizable"
  /// read concern for db.collection.aggregate(), you cannot include the
  /// $out stage in the pipeline.
  ///
  /// The $merge stage cannot be used in conjunction with read concern
  /// "linearizable". That is, if you specify "linearizable" read concern
  /// for db.collection.aggregate(), you cannot include the $merge stage
  /// in the pipeline.
  final ReadConcern readConcern;

  /// Specifies the [collation] to use for the operation.
  /// Collation allows users to specify language-specific rules for string
  /// comparison, such as rules for lettercase and accent marks.
  /// [See Collation document](https://docs.mongodb.com/manual/reference/collation/#collation-document-fields)
  ///
  /// If the collation is unspecified but the collection has a default
  /// collation (see db.createCollection()), the operation uses the collation
  /// specified for the collection.
  ///
  /// If no collation is specified for the collection or for the operations,
  /// MongoDB uses the simple binary comparison used in prior versions for
  /// string comparisons.
  ///
  /// You cannot specify multiple collations for an operation. For example,
  /// you cannot specify different collations per field, or if performing a
  /// find with a sort, you cannot use one collation for the find and another
  /// for the sort.
  ///
  /// New in version 3.4.
  final CollationOptions collation;

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

  /// A document that expresses the write concern to use with the $out or
  /// $merge stage.
  ///
  /// Omit to use the default write concern with the $out or $merge stage.
  final WriteConcern writeConcern;

  AggregateOptions(
      {this.allowDiskUse,
      this.maxTimeMS,
      this.bypassDocumentValidation,
      this.readConcern,
      this.collation,
      this.comment,
      this.writeConcern}) {
    if (maxTimeMS != null && maxTimeMS < 1) {
      throw MongoDartError('MaxTimeMS parameter must be a positive value');
    }
  }

  Map<String, Object> getOptions(Db db) => <String, Object>{
        if (allowDiskUse != null && allowDiskUse) keyAllowDiskUse: allowDiskUse,
        if (maxTimeMS != null) keyMaxTimeMS: maxTimeMS,
        if (bypassDocumentValidation != null && bypassDocumentValidation)
          keyBypassDocumentValidation: bypassDocumentValidation,
        if (readConcern != null) keyReadConcern: readConcern.toMap(),
        if (collation != null) keyCollation: collation.options,
        if (comment != null) keyComment: comment,
        if (writeConcern != null)
          keyWriteConcern:
              writeConcern.asMap(db.masterConnection?.serverStatus),
      };
}
