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
  final bool? repl;
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
      {this.assertsExcluded = false,
      this.connectionsExcluded = false,
      this.defaultRWConcernExcluded = false,
      this.electionMetricsExcluded = false,
      this.extra_infoExcluded = false,
      this.flowControlExcluded = false,
      this.freeMonitoringExcluded = false,
      this.globalLockExcluded = false,
      this.hedgingMetricsExcluded = false,
      this.latchAnalysisIncluded = false,
      this.logicalSessionRecordCacheExcluded = false,
      this.locksExcluded = false,
      this.memExcluded = false,
      this.metricsExcluded = false,
      this.mirroredReadsIncluded = false,
      this.networkExcluded = false,
      this.opLatenciesExcluded = false,
      this.opReadConcernCountersExcluded = false,
      this.opWriteConcernCountersExcluded = false,
      this.opcountersExcluded = false,
      this.opcountersReplExcluded = false,
      this.oplogTruncationExcluded = false,
      this.repl,
      this.securityExcluded = false,
      this.shardingExcluded = false,
      this.shardingStatisticsExcluded = false,
      this.shardedIndexConsistencyExcluded = false,
      this.storageEngineExcluded = false,
      this.transactionsExcluded = false,
      this.transportSecurityExcluded = false,
      this.watchdogExcluded = false,
      this.wiredTigerExcluded = false});

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
      //storageEngineExcluded: true,
      transactionsExcluded: true,
      transportSecurityExcluded: true,
      watchdogExcluded: true);

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
          if (repl!) keyRepl: 1 else keyRepl: 0,
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
