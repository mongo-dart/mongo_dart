import 'package:uuid/uuid.dart';

/// Server session must be assigned 1:1 with client sessions
/// server sessions persist after client session closing and can be reused
/// provided that only one client sessiona at a time can be
/// assigned to a server session
class ServerSession {
  /// When a driver needs to create a new ServerSession instance the only
  /// information it needs is the session ID to use for the new session.
  /// It can either get the session ID from the server by running the
  /// startSession command, or it can generate it locally.
  /// In either case, the lastUse field of the ServerSession MUST be set to
  /// the current time when the ServerSession is created.
  ServerSession(this.id) : lastUse = DateTime.now();
  UuidValue id;

  /// The driver MUST update the value of this property with the current
  /// DateTime every time the server session ID is sent to the server.
  /// This allows the driver to track with reasonable accuracy
  /// the server's view of when a server session was last used.
  DateTime lastUse;
}