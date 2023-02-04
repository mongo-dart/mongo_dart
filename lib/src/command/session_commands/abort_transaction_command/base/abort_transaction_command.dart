import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import '../../../../session/client_session.dart';
import '../../../../session/transaction_info.dart';
import '../../../base/operation_base.dart';
import '../open/abort_transaction_command_open.dart';
import '../v1/abort_transaction_command_v1.dart';
import 'abort_transaction_options.dart';

class AbortTransactionCommand extends DbAdminCommandOperation {
  @protected
  AbortTransactionCommand.protected(
      MongoClient client, TransactionInfo transactionInfo,
      {super.session,
      AbortTransactionOptions? abortTransactionOptions,
      Options? rawOptions})
      : super(client, <String, dynamic>{
          keyAbortTransaction: 1,
          //keyTxnNumber: transactionInfo.transactionNumber,
          //keyAutoabort: false
        }, options: <String, dynamic>{
          ...transactionInfo.options.getOptions(client),
          ...?abortTransactionOptions?.getOptions(client),
          ...?rawOptions
        });

  factory AbortTransactionCommand(
      MongoClient client, TransactionInfo transactionInfo,
      {ClientSession? session,
      AbortTransactionOptions? abortTransactionOptions,
      Options? rawOptions}) {
    if (client.serverApi != null) {
      switch (client.serverApi!.version) {
        case ServerApiVersion.v1:
          return AbortTransactionCommandV1(client, transactionInfo,
              session: session,
              abortTransactionOptions: abortTransactionOptions?.toV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${client.serverApi!.version} not managed');
      }
    }
    return AbortTransactionCommandOpen(client, transactionInfo,
        session: session,
        abortTransactionOptions: abortTransactionOptions?.toOpen,
        rawOptions: rawOptions);
  }
}
