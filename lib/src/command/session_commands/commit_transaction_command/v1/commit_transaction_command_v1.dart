import 'package:mongo_dart/src/command/session_commands/commit_transaction_command/base/commit_transaction_command.dart';

import 'commit_transaction_options_v1.dart';

class CommitTransactionCommandV1 extends CommitTransactionCommand {
  CommitTransactionCommandV1(super.client, super.transactionInfo,
      {CommitTransactionOptionsV1? commitTransactionOptions, super.rawOptions})
      : super.protected(commitTransactionOptions: commitTransactionOptions);
}
