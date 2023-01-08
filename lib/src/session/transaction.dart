import 'package:mongo_dart/src/topology/server.dart';

import 'transaction_options.dart';

enum TransactionState {
  none,
  starting,
  inProgress,
  committed,
  committedEmpty,
  aborted
}

class Transaction {
  Transaction({TransactionOptions? options})
      : options = options ?? TransactionOptions();
  TransactionOptions options;
  TransactionState state = TransactionState.none;
  Server? _pinnedServer;

  bool get isPinned => _pinnedServer != null;

  bool get isActive =>
      state == TransactionState.inProgress ||
      state == TransactionState.starting;
  bool get isCommitted =>
      state == TransactionState.committed ||
      state == TransactionState.committedEmpty ||
      state == TransactionState.aborted;

  void pinServer(server) {
    if (isActive) {
      _pinnedServer = server;
    }
  }

  void unpinServer() => _pinnedServer = null;
}
