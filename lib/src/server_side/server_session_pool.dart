import 'package:mongo_dart/src/settings/default_settings.dart';
import 'package:mongo_dart/src/topology/abstract/topology.dart';

import '../../mongo_dart.dart';
import 'server_session.dart';

class ServerSessionPool {
  ServerSessionPool(this.mongoClient);

  MongoClient mongoClient;
  List<ServerSession> sessions = <ServerSession>[];
  TopologyType get topologyType =>
      mongoClient.topology?.type ?? TopologyType.unknown;
  Duration get logicalSessionTimeoutMinutes =>
      mongoClient.topology?.logicalSessionTimeoutMinutes ??
      defLogicalSessionTimeoutMinutes;

  /// Algorithm to acquire a ServerSession instance from the server session pool
  /// - If the server session pool is empty create a new ServerSession and use it
  /// - Otherwise remove a ServerSession from the front of the queue and examine it:
  /// - If the driver is in load balancer mode, use this ServerSession.
  /// - If it has at least one minute left before becoming stale use this ServerSession
  /// - If it has less than one minute left before becoming stale discard it (let it be garbage collected) and return to step 1.
  /// See the [Load Balancer Specification](https://github.com/mongodb/specifications/blob/master/source/load-balancers/load-balancers.rst#session-expiration) for details on session expiration.
  /// A server session is considered stale by the server when it has not been
  /// used for a certain amount of time. The default amount of time is
  /// 30 minutes, but this value is configurable on the server.
  /// Servers that support sessions will report this value in the
  /// logicalSessionTimeoutMinutes field of the reply to the hello and
  /// legacy hello commands. The smallest reported timeout is recorded in the
  /// logicalSessionTimeoutMinutes property of the TopologyDescription.
  /// See the Server Discovery And Monitoring specification for details.
  ServerSession acquireSession() {
    ServerSession? selectedSession;
    while (selectedSession == null) {
      if (sessions.isEmpty) {
        selectedSession = ServerSession();
        break;
      }
      var possibleSession = sessions.removeAt(0);
      if (possibleSession.isDirty) {
        continue;
      }
      if (topologyType == TopologyType.loadBalancer) {
        selectedSession = possibleSession;
        break;
      }
      var staleDuration = DateTime.now().difference(possibleSession.lastUse);
      // If the session is stale or is becoming stale (one minute remaining)
      // it is discarded
      if (staleDuration.inMinutes >
          (logicalSessionTimeoutMinutes.inMinutes - 1)) {
        continue;
      }
      selectedSession = possibleSession;
      break;
    }

    return selectedSession;
  }

  // Todo
  void releaseServerSession(ServerSession session) {
    sessions.add(session);
  }
}
