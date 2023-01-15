import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';

import '../open/abort_transaction_options_open.dart';
import '../v1/abort_transaction_options_v1.dart';

/// GetParameter command options;
class AbortTransactionOptions {
  @protected
  const AbortTransactionOptions.protected({this.writeConcern, this.comment});

  factory AbortTransactionOptions(
      {ServerApi? serverApi, WriteConcern? writeConcern, String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return AbortTransactionOptionsV1(
          writeConcern: writeConcern, comment: comment);
    }
    return AbortTransactionOptionsOpen(
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

  AbortTransactionOptionsOpen get toOpen => this is AbortTransactionOptionsOpen
      ? this as AbortTransactionOptionsOpen
      : AbortTransactionOptionsOpen(
          writeConcern: writeConcern, comment: comment);

  AbortTransactionOptionsV1 get toV1 => this is AbortTransactionOptionsV1
      ? this as AbortTransactionOptionsV1
      : AbortTransactionOptionsV1(writeConcern: writeConcern, comment: comment);
  Options getOptions(MongoClient client) => <String, dynamic>{
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(
              client.topology?.primary?.serverStatus ??
                  (throw MongoDartError('No server detected'))),
        if (comment != null) keyComment: comment!,
      };
}
