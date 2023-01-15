import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';

import '../open/commit_transaction_options_open.dart';
import '../v1/commit_transaction_options_v1.dart';

/// GetParameter command options;
class CommitTransactionOptions {
  @protected
  const CommitTransactionOptions.protected({this.writeConcern, this.comment});

  factory CommitTransactionOptions(
      {ServerApi? serverApi, WriteConcern? writeConcern, String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return CommitTransactionOptionsV1(
          writeConcern: writeConcern, comment: comment);
    }
    return CommitTransactionOptionsOpen(
        writeConcern: writeConcern, comment: comment);
  }

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

  CommitTransactionOptionsOpen get toOpen =>
      this is CommitTransactionOptionsOpen
          ? this as CommitTransactionOptionsOpen
          : CommitTransactionOptionsOpen(
              writeConcern: writeConcern, comment: comment);

  CommitTransactionOptionsV1 get toV1 => this is CommitTransactionOptionsV1
      ? this as CommitTransactionOptionsV1
      : CommitTransactionOptionsV1(
          writeConcern: writeConcern, comment: comment);

  Options getOptions(MongoClient client) => <String, dynamic>{
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(
              client.topology?.primary?.serverStatus ??
                  (throw MongoDartError('No server detected'))),
        if (comment != null) keyComment: comment!,
      };
}
