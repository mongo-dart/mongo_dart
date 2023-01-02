import 'server_session.dart';

class ServerSessionPool {
  List<ServerSession> sessions = <ServerSession>[];

  // TODO
  /// Algorithm to acquire a ServerSession instance from the server session pool
  /// - If the server session pool is empty create a new ServerSession and use it
  /// - Otherwise remove a ServerSession from the front of the queue and examine it:
  /// - If the driver is in load balancer mode, use this ServerSession.
  /// - If it has at least one minute left before becoming stale use this ServerSession
  /// - If it has less than one minute left before becoming stale discard it (let it be garbage collected) and return to step 1.
  /// See the [Load Balancer Specification](https://github.com/mongodb/specifications/blob/master/source/load-balancers/load-balancers.rst#session-expiration) for details on session expiration.
  ServerSession acquireSession() {
    if (sessions.isEmpty) {
      return ServerSession();
    }
    return sessions.first;
  }

  // Todo
  void releaseServerSession(ServerSession session) {
    sessions.add(session);
  }
}
