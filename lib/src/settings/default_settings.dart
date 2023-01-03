int defMongoPort = 27017;
String defMongoDbName = 'test';
String defMongoAuthDbName = 'admin';

/// Polling time for waiting an available connection when the
/// maxPoolSize is exceeded
int defQueueTimeoutPollingMS = 50;

/// Default timeout in minutes for a server session to be considered stale
/// and consequently be canceld by the server.
/// The effective value is received in the Hello response, as ti can be
/// customized on the server
Duration defLogicalSessionTimeoutMinutes = Duration(minutes: 30);
