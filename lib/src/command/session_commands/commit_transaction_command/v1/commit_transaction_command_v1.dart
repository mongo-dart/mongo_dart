import 'package:mongo_dart/src/command/session_commands/commit_transaction_command/base/commit_transaction_command.dart';

import 'commit_transaction_options_v1.dart';

base class CommitTransactionCommandV1 extends CommitTransactionCommand {
  CommitTransactionCommandV1(super.client, super.transactionInfo,
      {super.session,
      CommitTransactionOptionsV1? commitTransactionOptions,
      super.rawOptions})
      : super.protected(commitTransactionOptions: commitTransactionOptions);
}
