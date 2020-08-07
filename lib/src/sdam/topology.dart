import '../cmap/events.dart';

// Global state
int globalTopologyCounter = 0;

// events that we relay to the `Topology`
const serverRelayEvents = <String>[
  'serverHeartbeatStarted',
  'serverHeartbeatSucceeded',
  'serverHeartbeatFailed',
  'commandStarted',
  'commandSucceeded',
  'commandFailed',

  // NOTE: Legacy events
  'monitoring',
  // Imported
  ...cmapEventNames
];

// all events we listen to from `Server` instances
const localServerEvents = ['connect', 'descriptionReceived', 'close', 'ended'];
