import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import '../../../../session/client_session.dart';
import '../../../../session/transaction_info.dart';
import '../../../base/operation_base.dart';
import '../open/commit_transaction_command_open.dart';
import '../v1/commit_transaction_command_v1.dart';
import 'commit_transaction_options.dart';

class CommitTransactionCommand extends DbAdminCommandOperation {
  @protected
  CommitTransactionCommand.protected(
      MongoClient client, TransactionInfo transactionInfo,
      {super.session,
      CommitTransactionOptions? commitTransactionOptions,
      Options? rawOptions})
      : super(client, <String, dynamic>{
          keyCommitTransaction: 1,
          //keyTxnNumber: transactionInfo.transactionNumber,
          //keyAutocommit: false
        }, options: <String, dynamic>{
          ...transactionInfo.options.getOptions(client),
          ...?commitTransactionOptions?.getOptions(client),
          ...?rawOptions
        });

  factory CommitTransactionCommand(
      MongoClient client, TransactionInfo transactionInfo,
      {ClientSession? session,
      CommitTransactionOptions? commitTransactionOptions,
      Options? rawOptions}) {
    if (client.serverApi != null) {
      switch (client.serverApi!.version) {
        case ServerApiVersion.v1:
          return CommitTransactionCommandV1(client, transactionInfo,
              session: session,
              commitTransactionOptions: commitTransactionOptions?.toV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${client.serverApi!.version} not managed');
      }
    }
    return CommitTransactionCommandOpen(client, transactionInfo,
        session: session,
        commitTransactionOptions: commitTransactionOptions?.toOpen,
        rawOptions: rawOptions);
  }
}
