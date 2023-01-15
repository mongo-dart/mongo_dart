import 'package:mongo_dart/src/command/session_commands/abort_transaction_command/base/abort_transaction_command.dart';

import 'abort_transaction_options_open.dart';

class AbortTransactionCommandOpen extends AbortTransactionCommand {
  AbortTransactionCommandOpen(super.client, super.transactionInfo,
      {AbortTransactionOptionsOpen? abortTransactionOptions, super.rawOptions})
      : super.protected(abortTransactionOptions: abortTransactionOptions);
}
