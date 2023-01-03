import 'package:uuid/uuid.dart';

import '../mongo_client.dart';
import '../server_side/server_session.dart';
import 'session_options.dart';

/// ClientSession instances are not thread safe or fork safe.
/// They can only be used by one thread or process at a time.
/// Drivers MUST NOT attempt to detect simultaneous use by multiple
///  threads or processes
///
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
  /// This sequence ensures that if the clusterTime of a ClientSession is invalid only that one session will be affected. The MongoClient clusterTime is only updated with $clusterTime values known to be valid because they were received directly from a server.
  DateTime? clusterTime;
  final SessionOptions sessionOptions;

  /// This property returns the session ID of this session.
  ///
  /// **Note** that since ServerSessions are pooled, different ClientSession
  /// instances can have the same session ID, but never at the same time.
  final UuidValue sessionId;

  ServerSession? serverSession;

  bool hasEnded = false;

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

  // Todo
  /// A driver MUST allow multiple calls to endSession.
  /// All calls after the first one are ignored.
  /// Conceptually, calling endSession implies ending the corresponding
  /// server session (by calling the endSessions command).
  /// As an implementation detail drivers SHOULD cache server sessions
  /// for reuse (see Server Session Pool).
  /// Once a ClientSession has ended, drivers MUST report an error if
  /// any operations are attempted with that ClientSession.
  endSession() {
    hasEnded = true;
    client.activeSessions.remove(this);
  }
}
