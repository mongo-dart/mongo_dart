import 'package:mongo_dart/src/command/session_commands/commit_transaction_command/base/commit_transaction_options.dart';

class CommitTransactionOptionsV1 extends CommitTransactionOptions {
  const CommitTransactionOptionsV1({super.writeConcern, super.comment})
      : super.protected();
}
