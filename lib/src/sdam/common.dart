
// shared state names
const stateClosing = 'closing';
const stateClosed = 'closed';
const stateConnecting = 'connecting';
const stateConnected = 'connected';

// An enumeration of topology types we know about
enum TopologyType  {
  single,
  replicaSetNoPrimary,
  replicaSetWithPrimary,
  sharded,
  unknown};

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
};

// helper to get a server's type that works for both legacy and unified topologies
ServerType serverType(server) {
  var description = server.s.description || server.s.serverDescription;
  if (description.topologyType == TopologyType.single) return description.servers[0].type;
  return description.type;
}

class TopologyDefaults {
  bool useUnifiedTopology = true;
  int localThresholdMS = 15;
  int serverSelectionTimeoutMS = 30000;
  int heartbeatFrequencyMS = 10000;
  int minHeartbeatFrequencyMS = 500;
};

void drainTimerQueue(Set queue) {
  queue.forEach(clearTimeout);
  queue.clear();
}

function clearAndRemoveTimerFrom(timer, timers) {
  clearTimeout(timer);
  return timers.delete(timer);
}
