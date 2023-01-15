import 'package:mongo_dart/src/command/session_commands/abort_transaction_command/base/abort_transaction_options.dart';

class AbortTransactionOptionsOpen extends AbortTransactionOptions {
  const AbortTransactionOptionsOpen({super.writeConcern, super.comment})
      : super.protected();
}
