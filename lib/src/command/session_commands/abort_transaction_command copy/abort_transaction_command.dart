import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import '../../../session/transaction_info.dart';
import '../../base/operation_base.dart';
import 'abort_transaction_options.dart';

class AbortTransactionCommand extends DbAdminCommandOperation {
  AbortTransactionCommand(MongoClient client, TransactionInfo transactionInfo,
      {AbortTransactionOptions? abortTransactionOptions, Options? rawOptions})
      : super(client, <String, dynamic>{
          keyCommitTransaction: 1,
          keyTxnNumber: transactionInfo.transactionNumber,
          keyAutocommit: false
        }, options: <String, dynamic>{
          ...transactionInfo.options.getOptions(client),
          ...?abortTransactionOptions?.getOptions(client),
          ...?rawOptions
        });
}
