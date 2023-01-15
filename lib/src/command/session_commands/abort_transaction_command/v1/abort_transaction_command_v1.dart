import 'package:mongo_dart/src/command/session_commands/abort_transaction_command/base/abort_transaction_command.dart';

import 'abort_transaction_options_v1.dart';

class AbortTransactionCommandV1 extends AbortTransactionCommand {
  AbortTransactionCommandV1(super.client, super.transactionInfo,
      {AbortTransactionOptionsV1? abortTransactionOptions, super.rawOptions})
      : super.protected(abortTransactionOptions: abortTransactionOptions);
}
