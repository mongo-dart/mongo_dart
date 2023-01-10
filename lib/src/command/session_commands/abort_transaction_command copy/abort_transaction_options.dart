import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';

/// GetParameter command options;
class AbortTransactionOptions {
  /// The WriteConcern for this insert operation
  final WriteConcern? writeConcern;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the following
  /// locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  /// We limit Comment to String only
  ///
  /// New in version 4.4.
  final String? comment;

  const AbortTransactionOptions({this.writeConcern, this.comment});

  Options getOptions(MongoClient client) => <String, dynamic>{
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(
              client.topology?.primary?.serverStatus ??
                  (throw MongoDartError('No server detected'))),
        if (comment != null) keyComment: comment!,
      };
}
