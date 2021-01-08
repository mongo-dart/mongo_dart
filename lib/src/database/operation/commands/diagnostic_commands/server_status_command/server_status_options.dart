import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// ServerStatus command options;
///
/// By default, serverStatus excludes in its output:
///    some content in the repl document.
///    mirroredReads document. (Available starting in version 4.4)
///
/// To include fields that are excluded by default,
/// specify the top-level field and set it to 1 in the command.
/// To exclude fields that are included by default,
/// specify the top-level field and set to 0 in the command.
/// [See](https://docs.mongodb.com/manual/reference/command/serverStatus/#syntax)
class ServerStatusOptions {
  final bool assertsExcluded;
  final bool connectionsExcluded;
  final bool defaultRWConcernExcluded;
  final bool electionMetricsExcluded;
  final bool extra_infoExcluded;
  final bool flowControlExcluded;
  final bool freeMonitoringExcluded;
  final bool globalLockExcluded;
  final bool hedgingMetricsExcluded;
// @Since 4.4
  final bool latchAnalysisIncluded;
  final bool logicalSessionRecordCacheExcluded;
  final bool locksExcluded;
  final bool memExcluded;
  final bool metricsExcluded;
  // @Since 4.4
  final bool mirroredReadsIncluded;
  final bool networkExcluded;
  final bool opLatenciesExcluded;
  final bool opReadConcernCountersExcluded;
  final bool opWriteConcernCountersExcluded;
  final bool opcountersExcluded;
  final bool opcountersReplExcluded;
  final bool oplogTruncationExcluded;
  final bool repl;
  final bool securityExcluded;
  final bool shardingExcluded;
  final bool shardingStatisticsExcluded;
  final bool shardedIndexConsistencyExcluded;
  final bool storageEngineExcluded;
  final bool transactionsExcluded;
  final bool transportSecurityExcluded;
  final bool watchdogExcluded;
  final bool wiredTigerExcluded;

  const ServerStatusOptions(
      {bool assertsExcluded,
      bool connectionsExcluded,
      bool defaultRWConcernExcluded,
      bool electionMetricsExcluded,
      bool extra_infoExcluded,
      bool flowControlExcluded,
      bool freeMonitoringExcluded,
      bool globalLockExcluded,
      bool hedgingMetricsExcluded,
      bool latchAnalysisIncluded,
      bool logicalSessionRecordCacheExcluded,
      bool locksExcluded,
      bool memExcluded,
      bool metricsExcluded,
      bool mirroredReadsIncluded,
      bool networkExcluded,
      bool opLatenciesExcluded,
      bool opReadConcernCountersExcluded,
      bool opWriteConcernCountersExcluded,
      bool opcountersExcluded,
      bool opcountersReplExcluded,
      bool oplogTruncationExcluded,
      this.repl,
      bool securityExcluded,
      bool shardingExcluded,
      bool shardingStatisticsExcluded,
      bool shardedIndexConsistencyExcluded,
      bool storageEngineExcluded,
      bool transactionsExcluded,
      bool transportSecurityExcluded,
      bool watchdogExcluded,
      bool wiredTigerExcluded})
      : assertsExcluded = assertsExcluded ?? false,
        connectionsExcluded = connectionsExcluded ?? false,
        defaultRWConcernExcluded = defaultRWConcernExcluded ?? false,
        electionMetricsExcluded = electionMetricsExcluded ?? false,
        extra_infoExcluded = extra_infoExcluded ?? false,
        flowControlExcluded = flowControlExcluded ?? false,
        freeMonitoringExcluded = freeMonitoringExcluded ?? false,
        globalLockExcluded = globalLockExcluded ?? false,
        hedgingMetricsExcluded = hedgingMetricsExcluded ?? false,
        latchAnalysisIncluded = latchAnalysisIncluded ?? false,
        logicalSessionRecordCacheExcluded =
            logicalSessionRecordCacheExcluded ?? false,
        locksExcluded = locksExcluded ?? false,
        memExcluded = memExcluded ?? false,
        metricsExcluded = metricsExcluded ?? false,
        mirroredReadsIncluded = mirroredReadsIncluded ?? false,
        networkExcluded = networkExcluded ?? false,
        opLatenciesExcluded = opLatenciesExcluded ?? false,
        opReadConcernCountersExcluded = opReadConcernCountersExcluded ?? false,
        opWriteConcernCountersExcluded =
            opWriteConcernCountersExcluded ?? false,
        opcountersExcluded = opcountersExcluded ?? false,
        opcountersReplExcluded = opcountersReplExcluded ?? false,
        oplogTruncationExcluded = oplogTruncationExcluded ?? false,
        securityExcluded = securityExcluded ?? false,
        shardingExcluded = shardingExcluded ?? false,
        shardingStatisticsExcluded = shardingStatisticsExcluded ?? false,
        shardedIndexConsistencyExcluded =
            shardedIndexConsistencyExcluded ?? false,
        storageEngineExcluded = storageEngineExcluded ?? false,
        transactionsExcluded = transactionsExcluded ?? false,
        transportSecurityExcluded = transportSecurityExcluded ?? false,
        watchdogExcluded = watchdogExcluded ?? false,
        wiredTigerExcluded = wiredTigerExcluded ?? false;

  static const ServerStatusOptions instance = ServerStatusOptions(
      assertsExcluded: true,
      connectionsExcluded: true,
      defaultRWConcernExcluded: true,
      electionMetricsExcluded: true,
      extra_infoExcluded: true,
      flowControlExcluded: true,
      freeMonitoringExcluded: true,
      globalLockExcluded: true,
      hedgingMetricsExcluded: true,
      logicalSessionRecordCacheExcluded: true,
      locksExcluded: true,
      memExcluded: true,
      metricsExcluded: true,
      networkExcluded: true,
      opLatenciesExcluded: true,
      opReadConcernCountersExcluded: true,
      opWriteConcernCountersExcluded: true,
      opcountersExcluded: true,
      opcountersReplExcluded: true,
      oplogTruncationExcluded: true,
      repl: true,
      securityExcluded: true,
      shardingExcluded: true,
      shardedIndexConsistencyExcluded: true,
      shardingStatisticsExcluded: true,
      storageEngineExcluded: true,
      transactionsExcluded: true,
      transportSecurityExcluded: true,
      watchdogExcluded: true,
      wiredTigerExcluded: true);

  static const ServerStatusOptions immutableValues = ServerStatusOptions(
      assertsExcluded: true,
      connectionsExcluded: true,
      defaultRWConcernExcluded: true,
      electionMetricsExcluded: true,
      extra_infoExcluded: true,
      flowControlExcluded: true,
      freeMonitoringExcluded: true,
      globalLockExcluded: true,
      hedgingMetricsExcluded: true,
      logicalSessionRecordCacheExcluded: true,
      locksExcluded: true,
      memExcluded: true,
      metricsExcluded: true,
      networkExcluded: true,
      opLatenciesExcluded: true,
      opReadConcernCountersExcluded: true,
      opWriteConcernCountersExcluded: true,
      opcountersExcluded: true,
      opcountersReplExcluded: true,
      oplogTruncationExcluded: true,
      repl: false,
      securityExcluded: true,
      shardingExcluded: true,
      shardedIndexConsistencyExcluded: true,
      shardingStatisticsExcluded: true,
      transactionsExcluded: true,
      transportSecurityExcluded: true,
      watchdogExcluded: true,
      wiredTigerExcluded: true);

  Map<String, Object> get options => <String, Object>{
        // The default has partial values, "1" - all, "0" - nothing
        if (repl != null)
          if (repl) keyRepl: 1 else keyRepl: 0,
        // Excluded by default
        if (mirroredReadsIncluded) keyMirroredReads: 1,
        if (latchAnalysisIncluded) keyLatchAnalysis: 1,
        // Included by default
        if (assertsExcluded) keyAsserts: 0,
        if (connectionsExcluded) keyConnections: 0,
        if (defaultRWConcernExcluded) keyDefaultRWConcern: 0,
        if (electionMetricsExcluded) keyElectionMetrics: 0,
        if (extra_infoExcluded) keyExtraInfo: 0,
        if (flowControlExcluded) keyFlowControl: 0,
        if (freeMonitoringExcluded) keyFreeMonitoring: 0,
        if (globalLockExcluded) keyGlobalLock: 0,
        if (hedgingMetricsExcluded) keyHedgingMetrics: 0,
        if (logicalSessionRecordCacheExcluded) keyLogicalSessionRecordCache: 0,
        if (locksExcluded) keyLocks: 0, if (memExcluded) keyMem: 0,
        if (metricsExcluded) keyMetrics: 0,
        if (networkExcluded) keyNetwork: 0,
        if (opLatenciesExcluded) keyOpLatencies: 0,
        if (opReadConcernCountersExcluded) keyOpReadConcernCounters: 0,
        if (opWriteConcernCountersExcluded) keyOpWriteConcernCounters: 0,
        if (opcountersExcluded) keyOpcounters: 0,
        if (opcountersReplExcluded) keyOpcountersRepl: 0,
        if (oplogTruncationExcluded) keyOplogTruncation: 0,
        if (securityExcluded) keySecurity: 0,
        if (shardingExcluded) keySharding: 0,
        if (shardingStatisticsExcluded) keyShardingStatistics: 0,
        if (shardedIndexConsistencyExcluded) keyShardedIndexConsistency: 0,
        if (storageEngineExcluded) keyStorageEngine: 0,
        if (transactionsExcluded) keyTransactions: 0,
        if (transportSecurityExcluded) keyTransportSecurity: 0,
        if (watchdogExcluded) keyWatchdog: 0,
        if (wiredTigerExcluded) keyWiredTiger: 0,
      };
}
