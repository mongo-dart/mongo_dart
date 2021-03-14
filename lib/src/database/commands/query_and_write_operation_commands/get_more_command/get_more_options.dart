import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// GetMore command options;
///
/// Optional parameters that can be used whith the getMore command:
/// `batchSize` 	positive integer
/// - The number of documents to return in the batch.
///   ** defaults to ** 101
/// `maxTimeMS` 	non-negative integer
/// - Specifies a time limit in milliseconds for processing operations
///   on a cursor. If you do not specify a value for maxTimeMS,
///   operations will not time out. A value of 0 explicitly specifies
///   the default unbounded behavior. MongoDB terminates operations
///   that exceed their allotted time limit using the same mechanism
///   as db.killOp(). MongoDB only terminates an operation at one of
///   its designated interrupt points.
///   Works only on tailable collections when the "awaitData" flag
///   has been set in the operation
/// `comment` 	string 	- @Since 4.4
/// - A user-provided comment to attach to this command. Once set,
///   this comment appears alongside records of this command in the
///   following locations:
///   * mongod log messages, in the attr.command.cursor.comment field.
///   * Database profiler output, in the command.comment field.
///   * currentOp output, in the command.comment field.
///
///   MongoDb allows any kind of BSON type for this option, but we are
///   limiting it to String only.
///
///   **NOTE** => If omitted, getMore inherits any comment set on the
///               originating find or aggregate command.
class GetMoreOptions {
  final int batchSize;
  final int maxTimeMS;
  final String comment;

  GetMoreOptions({int batchSize, this.maxTimeMS, this.comment})
      : batchSize = batchSize ?? 101 {
    if (this.batchSize < 1) {
      throw MongoDartError('batchSize parameter must be a positive integer');
    }
    if (maxTimeMS != null && maxTimeMS < 0) {
      throw MongoDartError(
          'maxTimeMS parameter must be a non-negative integer');
    }
  }

  Map<String, Object> get options => <String, Object>{
        if (batchSize != null) keyBatchSize: batchSize,
        if (maxTimeMS != null) keyMaxTimeMS: maxTimeMS,
        if (comment != null) keyComment: comment,
      };
}
