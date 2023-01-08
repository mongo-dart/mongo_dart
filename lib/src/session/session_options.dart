import 'package:mongo_dart/src/settings/default_settings.dart';

import '../command/command.dart';

class SessionOptions {
  bool causalConsistency = defSessionCausalConsistency;
  ReadConcern? readConcern;
  ReadPreference? readPreference;
  bool retryWrites = defSessionRetryWrites;
  WriteConcern? writeConcern;

  /// Specifies the maximum amount of time to allow a commit action on a
  /// transaction to run in milliseconds */
  int? defaultMaxCommitTimeMS;
}
