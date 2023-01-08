import '../command/command.dart';

class TransactionOptions {
  /// A default read concern for commands in this transaction */
  ReadConcern? readConcern;

  /// A default writeConcern for commands in this transaction */
  WriteConcern? writeConcern;

  /// A default read preference for commands in this transaction */
  ReadPreference? readPreference;

  /// Specifies the maximum amount of time to allow a commit action on a
  /// transaction to run in milliseconds */
  int? maxCommitTimeMS;
}
