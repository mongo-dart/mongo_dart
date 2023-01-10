import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import '../../../session/transaction_info.dart';
import '../../base/operation_base.dart';
import 'commit_transaction_options.dart';

class CommitTransactionCommand extends DbAdminCommandOperation {
  CommitTransactionCommand(MongoClient client, TransactionInfo transactionInfo,
      {CommitTransactionOptions? commitTransactionOptions, Options? rawOptions})
      : super(client, <String, dynamic>{
          keyCommitTransaction: 1,
          keyTxnNumber: transactionInfo.transactionNumber,
          keyAutocommit: false
        }, options: <String, dynamic>{
          ...transactionInfo.options.getOptions(client),
          ...?commitTransactionOptions?.getOptions(client),
          ...?rawOptions
        });
}
