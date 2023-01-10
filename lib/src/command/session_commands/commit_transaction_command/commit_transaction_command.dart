import 'package:fixnum/fixnum.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import 'commit_transaction_options.dart';

class CommitTransactionCommand extends DbAdminCommandOperation {
  CommitTransactionCommand(MongoClient client, Int64 txnNumber,
      {CommitTransactionOptions? commitTransactionOptions,
      Map<String, Object>? rawOptions})
      : super(client, <String, dynamic>{
          keyCommitTransaction: 1,
          keyTxnNumber: txnNumber,
          keyAutocommit: false
        }, options: <String, dynamic>{
          ...?commitTransactionOptions?.getOptions(client),
          ...?rawOptions
        });
}
