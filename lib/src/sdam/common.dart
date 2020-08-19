// shared state names
import 'package:mongo_dart/src/sdam/server.dart';

const stateClosing = 'closing';
const stateClosed = 'closed';
const stateConnecting = 'connecting';
const stateConnected = 'connected';

// An enumeration of topology types we know about
enum TopologyType {
  single,
  replicaSetNoPrimary,
  replicaSetWithPrimary,
  sharded,
  unknown
}

// An enumeration of server types we know about
enum ServerType {
  standalone,
  mongos,
  possiblePrimary,
  rSPrimary,
  rSSecondary,
  rSArbiter,
  rSOther,
  rSGhost,
  unknown
}

// helper to get a server's type that works for both legacy and unified topologies
ServerType serverType(Server server) {
  // Todo it seems that servers is the list of server names,
  //   but then the type is checked ?!? Verify
  /*  if (server.description.topologyType == TopologyType.single) {
    return server.description.ismaster.servers.first.type;
    } */
  return server.description.type;
}

class TopologyDefaults {
  bool useUnifiedTopology = true;
  int localThresholdMS = 15;
  int serverSelectionTimeoutMS = 30000;
  int heartbeatFrequencyMS = 10000;
  int minHeartbeatFrequencyMS = 500;
}

// Todo check, it is not clear the behavior
void drainTimerQueue(Set queue) {
  //queue.forEach(clearTimeout);
  queue.clear();
}

// Todo check, it is not clear the behavior
dynamic clearAndRemoveTimerFrom(timer, timers) {
  //clearTimeout(timer);
  return timers.remove(timer);
}
