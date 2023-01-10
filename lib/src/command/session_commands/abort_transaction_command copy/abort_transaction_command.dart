import 'package:fixnum/fixnum.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import 'abort_transaction_options.dart';

class AbortTransactionCommand extends DbAdminCommandOperation {
  AbortTransactionCommand(MongoClient client, Int64 txnNumber,
      {AbortTransactionOptions? commitTransactionOptions,
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
