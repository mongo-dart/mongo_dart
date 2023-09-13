import 'package:mongo_dart/src/command/session_commands/abort_transaction_command/base/abort_transaction_command.dart';
import 'package:mongo_dart/src/command/session_commands/abort_transaction_command/base/abort_transaction_options.dart';
import 'package:uuid/uuid.dart';

import '../command/base/operation_base.dart';
import '../command/session_commands/commit_transaction_command/base/commit_transaction_command.dart';
import '../command/session_commands/commit_transaction_command/base/commit_transaction_options.dart';
import '../core/error/mongo_dart_error.dart';
import '../database/document_types.dart';
import '../mongo_client.dart';
import '../server_side/server_session.dart';
import '../utils/map_keys.dart';
import 'session_options.dart';
import 'transaction_info.dart';
import 'transaction_options.dart';

/// ClientSession instances are not thread safe or fork safe.
/// They can only be used by one thread or process at a time.
/// Drivers MUST NOT attempt to detect simultaneous use by multiple
///  threads or processes
class ClientSession {
  ClientSession(this.client, {SessionOptions? sessionOptions})
      : sessionId = Uuid().v4obj(),
        sessionOptions = sessionOptions ?? SessionOptions() {
    client.activeSessions.add(this);
  }

  final MongoClient client;

  /// This property returns the most recent cluster time seen by this session.
  /// If no operations have been executed using this session this value will be
  /// null unless advanceClusterTime has been called. This value will also be
  /// null when a cluster does not report cluster times.
  /// When a driver is gossiping the cluster time it should send the more
  /// recent clusterTime of the ClientSession and the MongoClient
  ///
  /// The safe way to compute the $clusterTime to send to a server is:
  /// 1. When the ClientSession is first started its clusterTime is set to null.
  /// 2. When the driver sends $clusterTime to the server it should send the
  ///    greater of the ClientSession clusterTime and the MongoClient
  ///    clusterTime (either one could be null).
  /// 3. When the driver receives a $clusterTime from the server it should
  ///    advance both the ClientSession and the MongoClient clusterTime.
  ///    The clusterTime of a ClientSession can also be advanced by calling
  ///    advanceClusterTime.
  /// This sequence ensures that if the clusterTime of a ClientSession is
  ///    invalid only that one session will be affected.
  /// The MongoClient clusterTime is only updated with $clusterTime values
  ///    known to be valid because they were received directly from a server.
  DateTime? clusterTime;
  final SessionOptions sessionOptions;

  /// This property returns the session ID of this session.
  ///
  /// **Note** that since ServerSessions are pooled, different ClientSession
  /// instances can have the same session ID, but never at the same time.
  final UuidValue sessionId;

  ServerSession? serverSession;

  bool hasEnded = false;

  TransactionInfo? transaction;

  bool get isCausalConsistency => sessionOptions.causalConsistency;
  bool get shouldRetryWrite => sessionOptions.retryWrites;

  void advanceClusterTime(DateTime detectedClusterTime) {
    clusterTime ??= detectedClusterTime;
    if (detectedClusterTime.isAfter(clusterTime!)) {
      clusterTime = detectedClusterTime;
    }
    client.clientClusterTime ??= clusterTime;
    if (clusterTime!.isAfter(client.clientClusterTime!)) {
      client.clientClusterTime = clusterTime;
    }
  }

  // TODO
  /// A driver MUST allow multiple calls to endSession.
  /// All calls after the first one are ignored.
  /// Conceptually, calling endSession implies ending the corresponding
  /// server session (by calling the endSessions command).
  /// As an implementation detail drivers SHOULD cache server sessions
  /// for reuse (see Server Session Pool).
  /// Once a ClientSession has ended, drivers MUST report an error if
  /// any operations are attempted with that ClientSession.
  Future endSession() async {
    hasEnded = true;
    client.activeSessions.remove(this);
    if (inTransaction) {
      // TODO check which parameters are needed
      await abortTransaction();
    }
  }

  // ************   TRANSACTIONS   **********************
  bool get inTransaction => transaction?.isActive ?? false;
  // TODO check the case load balanced
  bool get isPinned => transaction?.isPinned ?? false;
  bool get isTransactionCommitted => transaction?.isCommitted ?? false;

  // TODO check the load balanced case
  void unpin(/* dynamic options */) {
    /*  if (this.loadBalanced) {
      return maybeClearPinnedConnection(this, options);
    } */

    transaction?.unpinServer();
  }

  /// Starts a new transaction with the given options.
  void startTransaction({TransactionOptions? transactionOptions}) {
    TransactionOptions options = transactionOptions ?? TransactionOptions();
    // TODO check
    /* if (this[kSnapshotEnabled]) {
      throw new MongoCompatibilityError('Transactions are not supported in snapshot sessions');
    } */

    if (inTransaction) {
      throw MongoDartError('Transaction already in progress');
    }

    if (isPinned && isTransactionCommitted) {
      unpin();
    }

    // create transaction state
    options.readConcern ??= sessionOptions.readConcern ?? client.readConcern;
    options.readPreference ??=
        sessionOptions.readPreference ?? client.readPreference;
    options.writeConcern ??= sessionOptions.writeConcern ?? client.writeConcern;
    options.maxCommitTimeMS ??= sessionOptions.defaultMaxCommitTimeMS;
    transaction = TransactionInfo(options: options)
      ..state = TransactionState.starting;
  }

  Future<MongoDocument?> abortTransaction(
      {AbortTransactionOptions? abortTransactionOptions,
      Options? options}) async {
    if (transaction == null) {
      throw MongoDartError('No transaction started');
    }
    // handle any initial problematic cases
    TransactionState txnState = transaction?.state ?? TransactionState.none;

    if (txnState == TransactionState.none) {
      throw MongoDartError('No transaction started');
    }

    if (txnState == TransactionState.starting) {
      // the transaction was never started, we can safely exit here
      transaction!.state = TransactionState.aborted;
      unpin();
      return null;
    }

    if (txnState == TransactionState.aborted) {
      throw MongoDartError('Cannot call abortTransaction twice');
    }

    if (txnState == TransactionState.committed ||
        txnState == TransactionState.committedEmpty) {
      throw MongoDartError(
          'Cannot call abortTransaction after calling commitTransaction');
    }

    var command = AbortTransactionCommand(client, transaction!,
        abortTransactionOptions: abortTransactionOptions, rawOptions: options);

    return command.process();
  }

  Future<MongoDocument?> commitTransaction(
      {CommitTransactionOptions? commitTransactionOptions,
      Options? options}) async {
    if (transaction == null) {
      throw MongoDartError('No transaction started');
    }
    // handle any initial problematic cases
    TransactionState txnState = transaction?.state ?? TransactionState.none;

    if (txnState == TransactionState.none) {
      throw MongoDartError('No transaction started');
    }

    if (txnState == TransactionState.starting ||
        txnState == TransactionState.committedEmpty) {
      // the transaction was never started, we can safely exit here
      transaction!.state = TransactionState.committedEmpty;
      return null;
    }

    if (txnState == TransactionState.aborted) {
      throw MongoDartError(
          'Cannot call commitTransaction after calling abortTransaction');
    }

    var command = CommitTransactionCommand(client, transaction!,
        commitTransactionOptions: commitTransactionOptions,
        rawOptions: options);

    return command.process();
  }

  void prepareCommand(Command command) {
    serverSession ??= client.serverSessionPool.acquireSession();
    serverSession!.lastUse = DateTime.now();
    command[keyLsid] = serverSession!.toMap;
    if (inTransaction) {
      if (transaction!.isFirstTransaction) {
        transaction!.transactionNumber =
            serverSession!.incrementTransactionNumber;
        command[keyStartTransaction] = true;
        transaction!.state = TransactionState.inProgress;
      }
      command[keyTxnNumber] = transaction!.transactionNumber;
      command[keyAutocommit] = false;
    }
  }

// TODO Execute the commands
/* Keep as reference
  Future<MongoDocument?> endTransaction(ClientSession session,
      {bool isAbort = false}) async {
    if (session.transaction == null) {
      throw MongoDartError('No transaction started');
    }
    // handle any initial problematic cases
    TransactionState txnState =
        session.transaction?.state ?? TransactionState.none;

    if (txnState == TransactionState.none) {
      throw MongoDartError('No transaction started');
    }

    if (!isAbort) {
      if (txnState == TransactionState.starting ||
          txnState == TransactionState.committedEmpty) {
        // the transaction was never started, we can safely exit here
        session.transaction!.state = TransactionState.committedEmpty;
        return null;
      }

      if (txnState == TransactionState.aborted) {
        throw MongoDartError(
            'Cannot call commitTransaction after calling abortTransaction');
      }
    } else {
      if (txnState == TransactionState.starting) {
        // the transaction was never started, we can safely exit here
        session.transaction!.state = TransactionState.aborted;
        unpin();
        return null;
      }

      if (txnState == TransactionState.aborted) {
        throw MongoDartError('Cannot call abortTransaction twice');
      }

      if (txnState == TransactionState.committed ||
          txnState == TransactionState.committedEmpty) {
        throw MongoDartError(
            'Cannot call abortTransaction after calling commitTransaction');
      }
    }


   // construct and send the command
  const command: Document = { [commandName]: 1 };

  // apply a writeConcern if specified
  let writeConcern;
  if (session.transaction.options.writeConcern) {
    writeConcern = Object.assign({}, session.transaction.options.writeConcern);
  } else if (session.clientOptions && session.clientOptions.writeConcern) {
    writeConcern = { w: session.clientOptions.writeConcern.w };
  }

  if (txnState == TransactionState.committed) {
    writeConcern = Object.assign({ wtimeout: 10000 }, writeConcern, { w: 'majority' });
  }

  if (writeConcern) {
    Object.assign(command, { writeConcern });
  }

  if (!isAbort && session.transaction.options.maxTimeMS) {
    Object.assign(command, { maxTimeMS: session.transaction.options.maxTimeMS });
  }

  function commandHandler(error?: Error, result?: Document) {
    if (commandName !== 'commitTransaction') {
      session.transaction.transition(TxnState.TRANSACTION_ABORTED);
      if (session.loadBalanced) {
        maybeClearPinnedConnection(session, { force: false });
      }

      // The spec indicates that we should ignore all errors on `abortTransaction`
      return callback();
    }

    session.transaction.transition(TxnState.TRANSACTION_COMMITTED);
    if (error instanceof MongoError) {
      if (
        error.hasErrorLabel(MongoErrorLabel.RetryableWriteError) ||
        error instanceof MongoWriteConcernError ||
        isMaxTimeMSExpiredError(error)
      ) {
        if (isUnknownTransactionCommitResult(error)) {
          error.addErrorLabel(MongoErrorLabel.UnknownTransactionCommitResult);

          // per txns spec, must unpin session in this case
          session.unpin({ error });
        }
      } else if (error.hasErrorLabel(MongoErrorLabel.TransientTransactionError)) {
        session.unpin({ error });
      }
    }

    callback(error, result);
  }

  if (session.transaction.recoveryToken) {
    command.recoveryToken = session.transaction.recoveryToken;
  }

  // send the command
  executeOperation(
    session.client,
    RunAdminCommandOperation(undefined, command, {
      session,
      readPreference: ReadPreference.primary,
      bypassPinningCheck: true
    }),
    (error, result) => {
      if (command.abortTransaction) {
        // always unpin on abort regardless of command outcome
        session.unpin();
      }

      if (error instanceof MongoError && error.hasErrorLabel(MongoErrorLabel.RetryableWriteError)) {
        // SPEC-1185: apply majority write concern when retrying commitTransaction
        if (command.commitTransaction) {
          // per txns spec, must unpin session in this case
          session.unpin({ force: true });

          command.writeConcern = Object.assign({ wtimeout: 10000 }, command.writeConcern, {
            w: 'majority'
          });
        }

        return executeOperation(
          session.client,
          RunAdminCommandOperation(undefined, command, {
            session,
            readPreference: ReadPreference.primary,
            bypassPinningCheck: true
          }),
          commandHandler
        );
      }

      commandHandler(error, result);
    }
  ); 
    return null;
  }*/
}
