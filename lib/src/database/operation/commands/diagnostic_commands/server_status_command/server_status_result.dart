import 'package:mongo_dart/src/database/operation/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Class representing the output of the ServerStatus command
/// Not all values are represented. If you need something that here is missing
/// use the execute method that returns the original Map document.
/// 
/// **Note**
/// The output fields vary depending on the version of MongoDB, underlying 
/// operating system platform, the storage engine, and the kind of node, 
/// including mongos, mongod or replica set member.
/// For the serverStatus output specific to the version of your MongoDB, 
/// refer to the appropriate version of the MongoDB Manual.

class ServerStatusResult with BasicResult {
  ServerStatusResult(Map<String, Object> document) {
    extractBasic(document);
    extractInstanceInfo(document);
    asserts = document[keyAsserts];
    connections = document[keyConnections];
    defaultRWConcern = document[keyDefaultRWConcern];
    electionMetrics = document[keyElectionMetrics];
    extraInfo = document[keyExtraInfo];
    flowControl = document[keyFlowControl];
    freeMonitoring = document[keyFreeMonitoring];
    globalLock = document[keyGlobalLock];
    hedgingMetrics = document[keyHedgingMetrics];
    latchAnalysis = document[keyLatchAnalysis];
    logicalSessionRecordCache = document[keyLogicalSessionRecordCache];
    locks = document[keyLocks];
    mirroredReads = document[keyMirroredReads];
    network = document[keyNetwork];
    opLatencies = document[keyOpLatencies];
    opReadConcernCounters = document[keyOpReadConcernCounters];
    opWriteConcernCounters = document[keyOpWriteConcernCounters];
    opcounters = document[keyOpcounters];
    opcountersRepl = document[keyOpcountersRepl];
    oplogTruncation = document[keyOplogTruncation];
    repl = document[keyRepl];
    security = document[keySecurity];
    sharding = document[keySharding];
    shardingStatistics = document[keyShardingStatistics];
    shardedIndexConsistency = document[keyShardedIndexConsistency];
    storageEngine = document[keyStorageEngine];
    transactions = document[keyTransactions];
    transportSecurity = document[keyTransportSecurity];
    wiredTiger = document[keyWiredTiger];
    writeBacksQueued = document[keyWriteBacksQueued];
    mem = document[keyMem];
    metrics = document[keyMetrics];
    watchdog = document[keyWatchdog];
  }

  // ***** INSTANCE INFORMATION ******
  /// The system’s hostname. In Unix/Linux systems, this should be the same
  /// as the output of the hostname command.
  String host;

  /// An array of the system’s fully qualified domain names (FQDNs).
  List<String> advisoryHostFQDNs;

  /// The MongoDB version of the current MongoDB process.
  String version;

  /// The current MongoDB process. Possible values are: mongos or mongod.
  String process;

  /// The process id number.
  int pid;

  /// The number of seconds that the current MongoDB process has been active.
  int uptime;

  /// The number of milliseconds that the current MongoDB process has
  /// been active.
  int uptimeMillis;

  /// The uptime in seconds as calculated from MongoDB’s internal
  /// course-grained time keeping system.
  int uptimeEstimate;

  /// The ISODate representing the current time, according to the server,
  /// in UTC.
  DateTime localTime;

  // **** ASSERTS ****
  /// A document that reports on the number of assertions raised since the
  /// MongoDB process started. While assert errors are typically uncommon,
  /// if there are non-zero values for the asserts, you should check the
  /// log file for more information. In many cases, these errors are trivial,
  /// but are worth investigating.
  /// "asserts" : {
  ///   "regular" : <num>,
  ///   "warning" : <num>,
  ///   "msg" : <num>,
  ///   "user" : <num>,
  ///   "rollovers" : <num>
  /// },
  Map<String, dynamic> asserts;

  // **** Connections ****
  /// A document that reports on the status of the connections.
  /// Use these values to assess the current load and capacity requirements
  /// of the server.
  /// "connections" : {
  ///   "current" : <num>,
  ///   "available" : <num>,
  ///   "totalCreated" : <num>,
  ///   "active" : <num>,
  ///   "exhaustIsMaster" : <num>,
  ///   "awaitingTopologyChanges" : <num>
  /// },
  /// @Since 4.4
  Map<String, dynamic> connections;

  // **** Default RWConcern ****
  /// The defaultRWConcern section provides information on the local copy
  /// of the global default read or write concern settings.
  /// The data may be stale or out of date.
  /// See [getDefaultRWConcern](https://docs.mongodb.com/manual/reference/command/getDefaultRWConcern/#dbcmd.getDefaultRWConcern)
  /// for more information.
  /// "defaultRWConcern" : {
  ///   "defaultReadConcern" : {
  ///     "level" : <string>
  ///   },
  ///   "defaultWriteConcern" : {
  ///     "w" : <string> | <int>,
  ///     "wtimeout" : <int>,
  ///     "j" : <bool>
  ///   },
  ///   "updateOpTime" : Timestamp,
  ///   "updateWallClockTime" : Date,
  ///   "localUpdateWallClockTime" : Date
  /// }
  /// @Since 4.4
  Map<String, dynamic> defaultRWConcern;

  // **** Election Metrics ****
  /// The electionMetrics section provides information on elections
  /// called by this mongod instance in a bid to become the primary:
  /// "electionMetrics" : {
  ///   "stepUpCmd" : {
  ///      "called" : <NumberLong>,
  ///      "successful" : <NumberLong>
  ///   },
  ///   "priorityTakeover" : {
  ///      "called" : <NumberLong>,
  ///      "successful" : <NumberLong>
  ///   },
  ///   "catchUpTakeover" : {
  ///      "called" : <NumberLong>,
  ///      "successful" : <NumberLong>
  ///   },
  ///   "electionTimeout" : {
  ///      "called" : <NumberLong>,
  ///      "successful" : <NumberLong>
  ///   },
  ///   "freezeTimeout" : {
  ///      "called" : <NumberLong>,
  ///      "successful" : <NumberLong>
  ///   },
  ///   "numStepDownsCausedByHigherTerm" : <NumberLong>,
  ///   "numCatchUps" : <NumberLong>,
  ///   "numCatchUpsSucceeded" : <NumberLong>,
  ///   "numCatchUpsAlreadyCaughtUp" : <NumberLong>,
  ///   "numCatchUpsSkipped" : <NumberLong>,
  ///   "numCatchUpsTimedOut" : <NumberLong>,
  ///   "numCatchUpsFailedWithError" :<NumberLong>,
  ///   "numCatchUpsFailedWithNewTerm" : <NumberLong>,
  ///   "numCatchUpsFailedWithReplSetAbortPrimaryCatchUpCmd" : <NumberLong>,
  ///   "averageCatchUpOps" : <double>
  /// }
  /// @Since 4.2.1 (or 4.0.13)
  Map<String, dynamic> electionMetrics;

  // **** Extra Info ****
  /// A document that provides additional information regarding the
  /// underlying system.
  /// "extra_info" : {
  ///   "note" : "fields vary by platform.",
  ///   "heap_usage_bytes" : <num>,
  ///   "page_faults" : <num>
  /// },
  ///
  Map<String, dynamic> extraInfo;

  // **** Flow Control ****
  /// A document that returns statistics on the Flow Control.
  /// With flow control enabled, as the majority commit point lag grows close
  /// to the flowControlTargetLagSeconds, writes on the primary must obtain
  /// tickets before taking locks. As such, the metrics returned are meaningful
  /// when run on the primary.
  /// "flowControl" : {
  ///   "enabled" : <boolean>,
  ///   "targetRateLimit" : <int>,
  ///   "timeAcquiringMicros" : <NumberLong>,
  ///   * Available in 4.4+. In 4.2, returned locksPerOp instead.
  ///   "locksPerKiloOp" : <double>,
  ///   "sustainerRate" : <int>,
  ///   "isLagged" : <boolean>,
  ///   "isLaggedCount" : <int>,
  ///   "isLaggedTimeMicros" : <NumberLong>,
  /// },
  /// @Since 4.2
  Map<String, dynamic> flowControl;

  // **** Free Monitoring ****
  /// A document that reports on the free Cloud monitoring.
  /// "freeMonitoring" : {
  ///   "state" : <string>,
  ///   "retryIntervalSecs" : <NumberLong>,
  ///   "lastRunTime" : <string>,
  ///   "registerErrors" : <NumberLong>,
  ///   "metricsErrors" : <NumberLong>
  /// },
  Map<String, dynamic> freeMonitoring;

  // **** Global Lock ****
  /// A document that reports on the database’s lock state.
  /// "globalLock" : {
  ///   "totalTime" : <num>,
  ///   "currentQueue" : {
  ///      "total" : <num>,
  ///      "readers" : <num>,
  ///      "writers" : <num>
  ///   },
  ///   "activeClients" : {
  ///      "total" : <num>,
  ///      "readers" : <num>,
  ///      "writers" : <num>
  ///   }
  /// },
  Map<String, dynamic> globalLock;

  // **** Hedging Metrics ****
  /// Provides metrics on hedged reads for the mongos instance.
  /// "hedgingMetrics" : {
  ///   "numTotalOperations" : <num>,
  ///   "numTotalHedgedOperations" : <num>,
  ///   "numAdvantageouslyHedgedOperations" : <num>
  /// },
  /// @Since 4.4
  Map<String, dynamic> hedgingMetrics;

  // **** Latch Analysis ****
  /// A document that reports on metrics related to internal locking primitives
  ///  (a.k.a. latches).
  ///   To return latchAnalysis information, you must explicitly specify
  ///   the inclusion:
  /// "latchAnalysis" : {
  ///   <latch name> : {
  ///      "created" : <num>,
  ///      "destroyed" : <num>,
  ///      "acquired" : <num>,
  ///      "released" : <num>,
  ///      "contended" : <num>,
  ///      "hierarchicalAcquisitionLevelViolations" : {
  ///            "onAcquire" : <num>,
  ///            "onRelease" : <num>
  ///      }
  ///   },
  ///  ...
  /// }
  /// @Since 4.4
  Map<String, dynamic> latchAnalysis;

  // **** Logical Session Record Cache ****
  /// Provides metrics around the caching of server sessions.
  /// "logicalSessionRecordCache" : {
  ///   "activeSessionsCount" : <num>,
  ///   "sessionsCollectionJobCount" : <num>,
  ///   "lastSessionsCollectionJobDurationMillis" : <num>,
  ///   "lastSessionsCollectionJobTimestamp" : <Date>,
  ///   "lastSessionsCollectionJobEntriesRefreshed" : <num>,
  ///   "lastSessionsCollectionJobEntriesEnded" : <num>,
  ///   "lastSessionsCollectionJobCursorsClosed" : <num>,
  ///   "transactionReaperJobCount" : <num>,
  ///   "lastTransactionReaperJobDurationMillis" : <num>,
  ///   "lastTransactionReaperJobTimestamp" : <Date>,
  ///   "lastTransactionReaperJobEntriesCleanedUp" : <num>,
  ///   "sessionCatalogSize" : <num>   // Starting in MongoDB 4.2
  /// },
  /// @Since 3.6
  Map<String, dynamic> logicalSessionRecordCache;

  // **** Locks ****
  /// A document that reports for each lock <type>, data on lock <modes>.
  /// The possible lock <types> are:
  /// Lock Type 	                 Description
  /// - ParallelBatchWriterMode 	 Represents a lock for parallel batch writer
  ///                              mode. In earlier versions, PBWM information
  ///                              was reported as part of the Global lock
  ///                              information. New in version 4.2.
  /// - ReplicationStateTransition Represents lock taken for replica set member
  ///                              state transitions. New in version 4.2.
  /// - Global 	                   Represents global lock.
  /// - Database 	                 Represents database lock.
  /// - Collection 	               Represents collection lock.
  /// - Mutex 	                   Represents mutex.
  /// - Metadata 	                 Represents metadata lock.
  /// - oplog 	                   Represents lock on the oplog.
  ///
  /// The possible <modes> are:
  /// Lock Mode 	                 Description
  ///  R 	                         Represents Shared (S) lock.
  ///  W 	                         Represents Exclusive (X) lock.
  ///  r 	                         Represents Intent Shared (IS) lock.
  ///  w 	                         Represents Intent Exclusive (IX) lock.
  ///
  ///  All values are of the NumberLong() type.
  /// "locks" : {
  ///   <type> : {
  ///         "acquireCount" : {
  ///            <mode> : NumberLong(<num>),
  ///            ...
  ///         },
  ///         "acquireWaitCount" : {
  ///            <mode> : NumberLong(<num>),
  ///            ...
  ///         },
  ///         "timeAcquiringMicros" : {
  ///            <mode> : NumberLong(<num>),
  ///            ...
  ///         },
  ///         "deadlockCount" : {
  ///            <mode> : NumberLong(<num>),
  ///            ...
  ///         }
  ///   },
  ///   ...
  /// }
  Map<String, dynamic> locks;

  // **** MirroredReads****
  /// A document that reports on mirrored reads. To return mirroredReads
  /// information, you must explicitly specify the inclusion:
  /// _Available on mongod only_.
  ///
  /// "mirroredReads" : {
  ///      "seen" : <num>,
  ///      "sent" : <num>
  /// },
  /// @Since 4.4
  Map<String, dynamic> mirroredReads;

  // **** Network ****
  /// A document that reports data on MongoDB’s network use.
  ///
  /// "network" : {
  ///   "bytesIn" : <num>,
  ///   "bytesOut" : <num>,
  ///   "numSlowDNSOperations" : <num>,
  ///   "numSlowSSLOperations" : <num>,
  ///   "numRequests" : <num>,
  ///   "tcpFastOpen" : {
  ///     "kernelSetting" : NumberLong("<num>"),
  ///     "serverSupported" : <bool>,
  ///     "clientSupported" : <bool>,
  ///     "accepted" : "NumberLong(<num>)"
  /// },
  Map<String, dynamic> network;

  // **** Op Latencies ****
  /// A document containing operation latencies for the instance as a whole.
  /// See latencyStats Document for an description of this document.
  /// _Only mongod instances report opLatencies_.
  ///
  /// "opLatencies" : {
  ///   "reads" : <document>,
  ///   "writes" : <document>,
  ///   "commands" : <document>
  /// },
  Map<String, dynamic> opLatencies;

  // **** Op Read Concern Counters ****
  /// A document that reports on the read concern level specified by query
  /// operations to the mongod instance since it last started.
  /// Specified w 	  Description
  /// "available" 	  Number of query operations that specified read concern
  ///                 level "available".
  /// "linearizable" 	Number of query operations that specified read concern
  ///                 level "linearizable".
  /// "local" 	      Number of query operations that specified read concern
  ///                 level "local".
  /// "majority" 	    Number of query operations that specified read concern
  ///                 level "majority".
  /// "snapshot" 	    Number of query operations that specified read concern
  ///                 level "snapshot".
  /// "none" 	        Number of query operations that did not specify a read
  ///                 concern level and instead used the default read concern level.
  /// The sum of the opReadConcernCounters equals opcounters.query.
  /// _Only for mongod instances_.
  ///
  /// "opReadConcernCounters" : {
  ///   "available" : NumberLong(<num>),
  ///   "linearizable" : NumberLong(<num>),
  ///   "local" : NumberLong(<num>),
  ///   "majority" : NumberLong(<num>),
  ///   "snapshot" : NumberLong(<num>),
  ///   "none" :  NumberLong(<num>)
  // }
  /// @Since 4.0.6
  Map<String, dynamic> opReadConcernCounters;

  // **** Op Write Concern Counters ****
  /// A document that reports on the write concerns specified by write
  /// operations to the mongod instance since it last started.
  /// More specifically, the opWriteConcernCounters reports on the w:
  /// <value> specified by the write operations.
  /// The journal flag option (j) and the timeout option (wtimeout) of the
  /// write concerns does not affect the count.
  /// The count is incremented even if the operation times out.
  /// **Note**
  /// Only available when reportOpWriteConcernCountersInServerStatus parameter
  /// is set to true (false by default).
  /// _Only for mongod instances_.
  ///
  /// "opWriteConcernCounters" : {
  ///   "insert" : {
  ///      "wmajority" : NumberLong(<num>),
  ///      "wnum" : {
  ///         "<num>" :  NumberLong(<num>),
  ///         ...
  ///      },
  ///      "wtag" : {
  ///         "<tag1>" :  NumberLong(<num>),
  ///         ...
  ///      },
  ///      "none" : NumberLong(<num>)
  ///   },
  ///   "update" : {
  ///      "wmajority" : NumberLong(<num>),
  ///      "wnum" : {
  ///         "<num>" :  NumberLong(<num>),
  ///      },
  ///      "wtag" : {
  ///         "<tag1>" :  NumberLong(<num>),
  ///         ...
  ///      },
  ///      "none" : NumberLong(<num>)
  ///   },
  ///   "delete" : {
  ///      "wmajority" :  NumberLong(<num>)
  ///      "wnum" : {
  ///         "<num>" :  NumberLong(<num>),
  ///         ...
  ///      },
  ///      "wtag" : {
  ///         "<tag1>" :  NumberLong(<num>),
  ///         ...
  ///      },
  ///      "none" : NumberLong(<num>)
  ///   }
  /// }
  /// @Since 4.0.6
  Map<String, dynamic> opWriteConcernCounters;

  // **** Opcounters ****
  /// A document that reports on database operations by type since the mongod
  /// instance last started.
  /// These numbers will grow over time until next restart.
  /// Analyze these values over time to track database utilization.
  ///
  /// **Note**
  /// The data in opcounters treats operations that affect multiple documents,
  /// such as bulk insert or multi-update operations, as a single operation.
  /// See metrics.document for more granular document-level operation tracking.
  /// Additionally, these values reflect received operations, and increment
  /// even when operations are not successful.
  ///
  /// "opcounters" : {
  ///   "insert" : NumberLong(<num>),  // Starting in MongoDB 4.2, type is NumberLong
  ///   "query" : NumberLong(<num>),   // Starting in MongoDB 4.2, type is NumberLong
  ///   "update" : NumberLong(<num>),  // Starting in MongoDB 4.2, type is NumberLong
  ///   "delete" : NumberLong(<num>),  // Starting in MongoDB 4.2, type is NumberLong
  ///   "getmore" : NumberLong(<num>), // Starting in MongoDB 4.2, type is NumberLong
  ///   "command" : NumberLong(<num>), // Starting in MongoDB 4.2, type is NumberLong
  /// },
  Map<String, dynamic> opcounters;

  // **** Opcounters Repl ****
  /// A document that reports on database replication operations by type since
  /// the mongod instance last started.
  /// These values only appear when the current host is a member of a replica
  /// set.
  /// These values will differ from the opcounters values because of how
  /// MongoDB serializes operations during replication. See Replication
  /// for more information on replication.
  /// These numbers will grow over time in response to database use until next
  /// restart. Analyze these values over time to track database utilization.
  /// Starting in MongoDB 4.2, the returned opcountersRepl.* values are type
  /// NumberLong. In previous versions, the values are type NumberInt.
  ///
  /// "opcountersRepl" : {
  ///   "insert" : NumberLong(<num>),  // Starting in MongoDB 4.2, type is NumberLong
  ///   "query" : NumberLong(<num>),   // Starting in MongoDB 4.2, type is NumberLong
  ///   "update" : NumberLong(<num>),  // Starting in MongoDB 4.2, type is NumberLong
  ///   "delete" : NumberLong(<num>),  // Starting in MongoDB 4.2, type is NumberLong
  ///   "getmore" : NumberLong(<num>), // Starting in MongoDB 4.2, type is NumberLong
  ///   "command" : NumberLong(<num>), // Starting in MongoDB 4.2, type is NumberLong
  /// },
  Map<String, dynamic> opcountersRepl;

  // **** Op Log Truncation ****
  /// A document that reports on oplog truncations.
  /// The field only appears when the current instance is a member of a replica
  /// set and uses either the WiredTiger Storage Engine or In-Memory
  /// Storage Engine.
  /// Changed in version 4.4: Also available in In-Memory Storage Engine.
  /// New in version 4.2.1: Available in the WiredTiger Storage Engine.
  ///
  /// "oplogTruncation" : {
  ///   "totalTimeProcessingMicros" : <NumberLong>,
  ///   "processingMethod" : <string>,
  ///   "oplogMinRetentionHours" : <double>
  ///   "totalTimeTruncatingMicros" : <NumberLong>,
  ///   "truncateCount" : <NumberLong>
  /// },
  Map<String, dynamic> oplogTruncation;

  // **** Repl ****
  /// A document that reports on the replica set configuration. repl only
  /// appear when the current host is a replica set. See Replication for more
  /// information on replication.
  ///
  /// "repl" : {
  ///   "hosts" : [
  ///         <string>,
  ///         <string>,
  ///         <string>
  ///   ],
  ///   "setName" : <string>,
  ///   "setVersion" : <num>,
  ///   "ismaster" : <boolean>,
  ///   "secondary" : <boolean>,
  ///   "primary" : <hostname>,
  ///   "me" : <hostname>,
  ///   "electionId" : ObjectId(""),
  ///   "rbid" : <num>,
  ///   "replicationProgress" : [
  ///         {
  ///            "rid" : <ObjectId>,
  ///            "optime" : { ts: <timestamp>, term: <num> },
  ///            "host" : <hostname>,
  ///            "memberId" : <num>
  ///         },
  ///        ...
  ///   ]
  /// }
  Map<String, dynamic> repl;

  // **** Security ****
  /// A document that reports on:
  /// The number of times a given authentication mechanism has been used to
  /// authenticate against the mongod / mongos instance. (New in MongoDB 4.4)
  /// The mongod/mongos instance’s TLS/SSL certificate.
  /// (Only appears for mongod / mongos instance with support for TLS)
  ///
  /// "security" : {
  ///   "authentication" : {
  ///      "mechanisms" : {
  ///         "MONGODB-X509" : {
  ///            "speculativeAuthenticate" : {
  ///               "received" : <num>,
  ///               "successful" : <num>
  ///            },
  ///            "authenticate" : {
  ///               "received" : <num>,
  ///               "successful" : <num>
  ///            }
  ///         },
  ///         "SCRAM-SHA-1" : {
  ///            "speculativeAuthenticate" : {
  ///               "received" : <num>,
  ///               "successful" : <num>
  ///            },
  ///            "authenticate" : {
  ///               "received" : <num>,
  ///               "successful" : <num>
  ///            }
  ///         },
  ///         "SCRAM-SHA-256" : {
  ///            "speculativeAuthenticate" : {
  ///               "received" : <num>,
  ///               "successful" : <num>
  ///            },
  ///            "authenticate" : {
  ///               "received" : <num>,
  ///               "successful" : <num>
  ///            }
  ///          }
  ///       }
  ///     },
  ///     "SSLServerSubjectName": <string>,
  ///     "SSLServerHasCertificateAuthority": <boolean>,
  ///     "SSLServerCertificateExpirationDate": <date>
  /// },
  Map<String, dynamic> security;

  // **** Sharding ****
  /// A document with data regarding the sharded cluster.
  /// The lastSeenConfigServerOpTime is present only for a mongos or a shard
  ///  member, not for a config server.
  ///
  /// New in version 3.2: When run on mongos, the command returns sharding
  /// information.
  /// Changed in version 3.6: Starting in MongoDB 3.6, shard members
  /// return sharding information.
  ///
  /// "sharding" :{
  ///   "configsvrConnectionString" : "csRS/cfg1.example.net:27019,"
  ///       "cfg2.example.net:27019,cfg2.example.net:27019",
  ///   "lastSeenConfigServerOpTime" : {
  ///      "ts" : Timestamp(1517462189, 1),
  ///      "t" : NumberLong(1)
  ///   },
  ///   "maxChunkSizeInBytes" : NumberLong(67108864)
  /// }
  Map<String, dynamic> sharding;

  // **** Sharding Statistics ****
  /// A document which contains metrics on metadata refresh on sharded clusters.
  ///
  /// New in version 4.0.
  ///
  /// When run on a member of a shard:
  /// "shardingStatistics" : {
  ///   "countStaleConfigErrors" : NumberLong(<num>),
  ///   "countDonorMoveChunkStarted" : NumberLong(<num>),
  ///   "totalDonorChunkCloneTimeMillis" : NumberLong(<num>),
  ///   "totalCriticalSectionCommitTimeMillis" : NumberLong(<num>),
  ///   "totalCriticalSectionTimeMillis" : NumberLong(<num>),
  ///   "countDocsClonedOnRecipient" : NumberLong(<num>),
  ///   "countDocsClonedOnDonor" : NumberLong(<num>),
  ///   "countRecipientMoveChunkStarted" : NumberLong(<num>),
  ///   "countDocsDeletedOnDonor" : NumberLong(<num>),
  ///   "countDonorMoveChunkLockTimeout" : NumberLong(<num>),
  ///   "unfinishedMigrationFromPreviousPrimary" : NumberLong(<num>),
  ///   "catalogCache" : {
  ///      "numDatabaseEntries" : NumberLong(<num>),
  ///      "numCollectionEntries" : NumberLong(<num>),
  ///      "countStaleConfigErrors" : NumberLong(<num>),
  ///      "totalRefreshWaitTimeMicros" : NumberLong(<num>),
  ///      "numActiveIncrementalRefreshes" : NumberLong(<num>),
  ///      "countIncrementalRefreshesStarted" : NumberLong(<num>),
  ///      "numActiveFullRefreshes" : NumberLong(<num>),
  ///      "countFullRefreshesStarted" : NumberLong(<num>),
  ///      "countFailedRefreshes" : NumberLong(<num>)
  ///   },
  ///   "rangeDeleterTasks" : <num>
  /// },
  ///
  /// When run on a mongos:
  /// "shardingStatistics" : {
  ///   "catalogCache" : {
  ///      "numDatabaseEntries" : NumberLong(<num>),
  ///      "numCollectionEntries" : NumberLong(<num>),
  ///      "countStaleConfigErrors" : NumberLong(<num>),
  ///      "totalRefreshWaitTimeMicros" : NumberLong(<num>),
  ///      "numActiveIncrementalRefreshes" : NumberLong(<num>),
  ///      "countIncrementalRefreshesStarted" : NumberLong(<num>),
  ///      "numActiveFullRefreshes" : NumberLong(<num>),
  ///      "countFullRefreshesStarted" : NumberLong(<num>),
  ///      "countFailedRefreshes" : NumberLong(<num>),
  ///      "operationsBlockedByRefresh" : {
  ///        "countAllOperations" : NumberLong(<num>),
  ///        "countInserts" : NumberLong(<num>),
  ///        "countQueries" : NumberLong(<num>),
  ///        "countUpdates" : NumberLong(<num>),
  ///        "countDeletes" : NumberLong(<num>),
  ///        "countCommands" : NumberLong(<num>)
  ///      }
  ///   }
  /// },
  Map<String, dynamic> shardingStatistics;

  // **** Sharded Index Consistency ****
  /// Available only on config server instances.
  /// A document that returns results of index consistency checks for sharded
  /// collections.
  /// The returned metrics are meaningful only when run on the primary of the
  /// config server replica set for a version 4.4+ (and 4.2.6+) sharded cluster.
  /// See also
  /// -  [enableShardedIndexConsistencyCheck](https://docs.mongodb.com/manual/reference/parameters/#param.enableShardedIndexConsistencyCheck) parameter
  /// -  [shardedIndexConsistencyCheckIntervalMS](https://docs.mongodb.com/manual/reference/parameters/#param.shardedIndexConsistencyCheckIntervalMS) parameter
  /// New in version 4.4. (and 4.2.6)
  ///
  /// "shardedIndexConsistency" : {
  ///   "numShardedCollectionsWithInconsistentIndexes" : <NumberLong>
  /// },
  Map<String, dynamic> shardedIndexConsistency;

  // **** Storage Engine ****
  /// A document with data about the current storage engine.
  ///
  /// "storageEngine" : {
  ///   "name" : <string>,
  ///   "supportsCommittedReads" : <boolean>,
  ///   "persistent" : <boolean>
  /// },
  Map<String, dynamic> storageEngine;

  // **** Transactions ****
  /// When run on a mongod, a document with data about the retryable
  ///  writes and transactions.
  /// When run on a mongos, a document with data about the transactions
  /// run on the instance.
  ///
  /// Available on mongod in 3.6.3+ and on mongos in 4.2+.
  ///
  ///  On Mongod:
  /// "transactions" : {
  ///   "retriedCommandsCount" : <NumberLong>,
  ///   "retriedStatementsCount" : <NumberLong>,
  ///   "transactionsCollectionWriteCount" : <NumberLong>,
  ///   "currentActive" : <NumberLong>,
  ///   "currentInactive" : <NumberLong>,
  ///   "currentOpen" : <NumberLong>,
  ///   "totalAborted" : <NumberLong>,
  ///   "totalCommitted" : <NumberLong>,
  ///   "totalStarted" : <NumberLong>,
  ///   "totalPrepared" : <NumberLong>,
  ///   "totalPreparedThenCommitted" : <NumberLong>,
  ///   "totalPreparedThenAborted" :  <NumberLong>,
  ///   "currentPrepared" :  <NumberLong>,
  ///   "lastCommittedTransaction" : <document> // Starting in 4.2.2 (and 4.0.9)
  /// },
  ///
  /// On Mongos:
  /// "transactions" : {
  ///   "currentOpen" : <NumberLong>,     // Starting in 4.2.1
  ///   "currentActive" : <NumberLong>,   // Starting in 4.2.1
  ///   "currentInactive" : <NumberLong>, // Starting in 4.2.1
  ///   "totalStarted" : <NumberLong>,
  ///   "totalCommitted" : <NumberLong>,
  ///   "totalAborted" : <NumberLong>,
  ///   "abortCause" : {
  ///      <String1> : <NumberLong>,
  ///      <String2>" : <NumberLong>,
  ///      ...
  ///   },
  ///   "totalContactedParticipants" : <NumberLong>,
  ///   "totalParticipantsAtCommit" : <NumberLong>,
  ///   "totalRequestsTargeted" : <NumberLong>,
  ///   "commitTypes" : {
  ///      "noShards" : {
  ///         "initiated" : <NumberLong>,
  ///         "successful" : <NumberLong>,
  ///         "successfulDurationMicros" : <NumberLong>,
  ///      },
  ///      "singleShard" : {
  ///         "initiated" : <NumberLong>,
  ///         "successful" : <NumberLong>,
  ///         "successfulDurationMicros" : <NumberLong>,
  ///      },
  ///      "singleWriteShard" : {
  ///         "initiated" : <NumberLong>,
  ///         "successful" : <NumberLong>,
  ///         "successfulDurationMicros" : <NumberLong>,
  ///      },
  ///      "readOnly" : {
  ///         "initiated" : <NumberLong>,
  ///         "successful" : <NumberLong>,
  ///         "successfulDurationMicros" : <NumberLong>,
  ///      },
  ///      "twoPhaseCommit" : {
  ///         "initiated" : <NumberLong>,
  ///         "successful" : <NumberLong>,
  ///         "successfulDurationMicros" :<NumberLong>,
  ///      },
  ///      "recoverWithToken" : {
  ///         "initiated" : <NumberLong>,
  ///         "successful" : <NumberLong>,
  ///         "successfulDurationMicros" : <NumberLong>,
  ///      }
  ///   }
  /// },
  Map<String, dynamic> transactions;

  // **** Transport Security ****
  /// The cumulative number of TLS <version> connections that have been made
  /// to this mongod or mongos instance. The value is reset upon restart.
  ///
  /// New in version 4.0.2: (Also available in 3.6.7+ and 3.4.17+)
  ///
  /// "transportSecurity" : {
  ///   "1.0" : <NumberLong>,
  ///   "1.1" : <NumberLong>,
  ///   "1.2" : <NumberLong>,
  ///   "1.3" : <NumberLong>,
  ///   "unknown" :<NumberLong>
  /// },
  Map<String, dynamic> transportSecurity;

  // **** Wired Tiger ****
  /// wiredTiger information only appears if using the WiredTiger storage
  /// engine. Some of the statistics roll up for the server.
  ///
  /// "wiredTiger" : {
  ///   "uri" : "statistics:",
  ///   "async" : {
  ///      "current work queue length" : <num>,
  ///      "maximum work queue length" : <num>,
  ///      "number of allocation state races" : <num>,
  ///      "number of flush calls" : <num>,
  ///      "number of operation slots viewed for allocation" : <num>,
  ///      "number of times operation allocation failed" : <num>,
  ///      "number of times worker found no work" : <num>,
  ///      "total allocations" : <num>,
  ///      "total compact calls" : <num>,
  ///      "total insert calls" : <num>,
  ///      "total remove calls" : <num>,
  ///      "total search calls" : <num>,
  ///      "total update calls" : <num>
  ///   },
  ///   "block-manager" : {
  ///      "blocks pre-loaded" : <num>,
  ///      "blocks read" : <num>,
  ///      "blocks written" : <num>,
  ///      "bytes read" : <num>,
  ///      "bytes written" : <num>,
  ///      "bytes written for checkpoint" : <num>,
  ///      "mapped blocks read" : <num>,
  ///      "mapped bytes read" : <num>
  ///   },
  ///   "cache" : {
  ///      "application threads page read from disk to cache count" : <num>,
  ///      "application threads page read from disk to cache time (usecs)" : <num>,
  ///      "application threads page write from cache to disk count" : <num>,
  ///      "application threads page write from cache to disk time (usecs)" : <num>,
  ///      "bytes belonging to page images in the cache" : <num>,
  ///      "bytes belonging to the cache overflow table in the cache" : <num>,
  ///      "bytes currently in the cache" : <num>,
  ///      "bytes dirty in the cache cumulative" : <num>,
  ///      "bytes not belonging to page images in the cache" : <num>,
  ///      "bytes read into cache" : <num>,
  ///      "bytes written from cache" : <num>,
  ///      "cache overflow cursor application thread wait time (usecs)" : <num>,
  ///      "cache overflow cursor internal thread wait time (usecs)" : <num>,
  ///      "cache overflow score" : <num>,
  ///      "cache overflow table entries" : <num>,
  ///      "cache overflow table insert calls" : <num>,
  ///      "cache overflow table max on-disk size" : <num>,
  ///      "cache overflow table on-disk size" : <num>,
  ///      "cache overflow table remove calls" : <num>,
  ///      "checkpoint blocked page eviction" : <num>,
  ///      "eviction calls to get a page" : <num>,
  ///      "eviction calls to get a page found queue empty" : <num>,
  ///      "eviction calls to get a page found queue empty after locking" : <num>,
  ///      "eviction currently operating in aggressive mode" : <num>,
  ///      "eviction empty score" : <num>,
  ///      "eviction passes of a file" : <num>,
  ///      "eviction server candidate queue empty when topping up" : <num>,
  ///      "eviction server candidate queue not empty when topping up" : <num>,
  ///      "eviction server evicting pages" : <num>,
  ///      "eviction server slept, because we did not make progress with eviction" : <num>,
  ///      "eviction server unable to reach eviction goal" : <num>,
  ///      "eviction server waiting for a leaf page" : <num>,
  ///      "eviction server waiting for an internal page sleep (usec)" : <num>,
  ///      "eviction server waiting for an internal page yields" : <num>,
  ///      "eviction state" : <num>,
  ///      "eviction walk target pages histogram - 0-9" : <num>,
  ///      "eviction walk target pages histogram - 10-31" : <num>,
  ///      "eviction walk target pages histogram - 128 and higher" : <num>,
  ///      "eviction walk target pages histogram - 32-63" : <num>,
  ///      "eviction walk target pages histogram - 64-128" : <num>,
  ///      "eviction walks abandoned" : <num>,
  ///      "eviction walks gave up because they restarted their walk twice" : <num>,
  ///      "eviction walks gave up because they saw too many pages and found no candidates" : <num>,
  ///      "eviction walks gave up because they saw too many pages and found too few candidates" : <num>,
  ///      "eviction walks reached end of tree" : <num>,
  ///      "eviction walks started from root of tree" : <num>,
  ///      "eviction walks started from saved location in tree" : <num>,
  ///      "eviction worker thread active" : <num>,
  ///      "eviction worker thread created" : <num>,
  ///      "eviction worker thread evicting pages" : <num>,
  ///      "eviction worker thread removed" : <num>,
  ///      "eviction worker thread stable number" : <num>,
  ///      "files with active eviction walks" : <num>,
  ///      "files with new eviction walks started" : <num>,
  ///      "force re-tuning of eviction workers once in a while" : <num>,
  ///      "forced eviction - pages evicted that were clean count" : <num>,
  ///      "forced eviction - pages evicted that were clean time (usecs)" : <num>,
  ///      "forced eviction - pages evicted that were dirty count" : <num>,
  ///      "forced eviction - pages evicted that were dirty time (usecs)" : <num>,
  ///      "forced eviction - pages selected because of too many deleted items count" : <num>,
  ///      "forced eviction - pages selected count" : <num>,
  ///      "forced eviction - pages selected unable to be evicted count" : <num>,
  ///      "forced eviction - pages selected unable to be evicted time" : <num>,
  ///      "hazard pointer blocked page eviction" : <num>,
  ///      "hazard pointer check calls" : <num>,
  ///      "hazard pointer check entries walked" : <num>,
  ///      "hazard pointer maximum array length" : <num>,
  ///      "in-memory page passed criteria to be split" : <num>,
  ///      "in-memory page splits" : <num>,
  ///      "internal pages evicted" : <num>,
  ///      "internal pages split during eviction" : <num>,
  ///      "leaf pages split during eviction" : <num>,
  ///      "maximum bytes configured" : <num>,
  ///      "maximum page size at eviction" : <num>,
  ///      "modified pages evicted" : <num>,
  ///      "modified pages evicted by application threads" : <num>,
  ///      "operations timed out waiting for space in cache" : <num>,
  ///      "overflow pages read into cache" : <num>,
  ///      "page split during eviction deepened the tree" : <num>,
  ///      "page written requiring cache overflow records" : <num>,
  ///      "pages currently held in the cache" : <num>,
  ///      "pages evicted by application threads" : <num>,
  ///      "pages queued for eviction" : <num>,
  ///      "pages queued for eviction post lru sorting" : <num>,
  ///      "pages queued for urgent eviction" : <num>,
  ///      "pages queued for urgent eviction during walk" : <num>,
  ///      "pages read into cache" : <num>,
  ///      "pages read into cache after truncate" : <num>,
  ///      "pages read into cache after truncate in prepare state" : <num>,
  ///      "pages read into cache requiring cache overflow entries" : <num>,
  ///      "pages read into cache requiring cache overflow for checkpoint" : <num>,
  ///      "pages read into cache skipping older cache overflow entries" : <num>,
  ///      "pages read into cache with skipped cache overflow entries needed later" : <num>,
  ///      "pages read into cache with skipped cache overflow entries needed later by checkpoint" : <num>,
  ///      "pages requested from the cache" : <num>,
  ///      "pages seen by eviction walk" : <num>,
  ///      "pages selected for eviction unable to be evicted" : <num>,
  ///      "pages walked for eviction" : <num>,
  ///      "pages written from cache" : <num>,
  ///      "pages written requiring in-memory restoration" : <num>,
  ///      "percentage overhead" : <num>,
  ///      "tracked bytes belonging to internal pages in the cache" : <num>,
  ///      "tracked bytes belonging to leaf pages in the cache" : <num>,
  ///      "tracked dirty bytes in the cache" : <num>,
  ///      "tracked dirty pages in the cache" : <num>,
  ///      "unmodified pages evicted" : <num>
  ///   },
  ///   "capacity" : {
  ///      "background fsync file handles considered" : <num>,
  ///      "background fsync file handles synced" : <num>,
  ///      "background fsync time (msecs)" : <num>,
  ///      "bytes read" : <num>,
  ///      "bytes written for checkpoint" : <num>,
  ///      "bytes written for eviction" : <num>,
  ///      "bytes written for log" : <num>,
  ///      "bytes written total" : <num>,
  ///      "threshold to call fsync" : <num>,
  ///      "time waiting due to total capacity (usecs)" : <num>,
  ///      "time waiting during checkpoint (usecs)" : <num>,
  ///      "time waiting during eviction (usecs)" : <num>,
  ///      "time waiting during logging (usecs)" : <num>,
  ///      "time waiting during read (usecs)" : <num>
  ///   },
  ///   "connection" : {
  ///      "auto adjusting condition resets" : <num>,
  ///      "auto adjusting condition wait calls" : <num>,
  ///      "detected system time went backwards" : <num>,
  ///      "files currently open" : <num>,
  ///      "memory allocations" : <num>,
  ///      "memory frees" : <num>,
  ///      "memory re-allocations" : <num>,
  ///      "pthread mutex condition wait calls" : <num>,
  ///      "pthread mutex shared lock read-lock calls" : <num>,
  ///      "pthread mutex shared lock write-lock calls" : <num>,
  ///      "total fsync I/Os" : <num>,
  ///      "total read I/Os" : <num>,
  ///      "total write I/Os" : <num>
  ///   },
  ///   "cursor" : {
  ///      "cached cursor count" : <num>,
  ///      "cursor bulk loaded cursor insert calls" : <num>,
  ///      "cursor close calls that result in cache" : <num>,
  ///      "cursor create calls" : <num>,
  ///      "cursor insert calls" : <num>,
  ///      "cursor insert key and value bytes" : <num>,
  ///      "cursor modify calls" : <num>,
  ///      "cursor modify key and value bytes affected" : <num>,
  ///      "cursor modify value bytes modified" : <num>,
  ///      "cursor next calls" : <num>,
  ///      "cursor operation restarted" : <num>,
  ///      "cursor prev calls" : <num>,
  ///      "cursor remove calls" : <num>,
  ///      "cursor remove key bytes removed" : <num>,
  ///      "cursor reserve calls" : <num>,
  ///      "cursor reset calls" : <num>,
  ///      "cursor search calls" : <num>,
  ///      "cursor search near calls" : <num>,
  ///      "cursor sweep buckets" : <num>,
  ///      "cursor sweep cursors closed" : <num>,
  ///      "cursor sweep cursors examined" : <num>,
  ///      "cursor sweeps" : <num>,
  ///      "cursor truncate calls" : <num>,
  ///      "cursor update calls" : <num>,
  ///      "cursor update key and value bytes" : <num>,
  ///      "cursor update value size change" : <num>,
  ///      "cursors reused from cache" : <num>,
  ///      "open cursor count" : <num>
  ///   },
  ///   "data-handle" : {
  ///      "connection data handle size" : <num>,
  ///      "connection data handles currently active" : <num>,
  ///      "connection sweep candidate became referenced" : <num>,
  ///      "connection sweep dhandles closed" : <num>,
  ///      "connection sweep dhandles removed from hash list" : <num>,
  ///      "connection sweep time-of-death sets" : <num>,
  ///      "connection sweeps" : <num>,
  ///      "session dhandles swept" : <num>,
  ///      "session sweep attempts" : <num>
  ///   },
  ///   "lock" : {
  ///      "checkpoint lock acquisitions" : <num>,
  ///      "checkpoint lock application thread wait time (usecs)" : <num>,
  ///      "checkpoint lock internal thread wait time (usecs)" : <num>,
  ///      "dhandle lock application thread time waiting (usecs)" : <num>,
  ///      "dhandle lock internal thread time waiting (usecs)" : <num>,
  ///      "dhandle read lock acquisitions" : <num>,
  ///      "dhandle write lock acquisitions" : <num>,
  ///      "durable timestamp queue lock application thread time waiting (usecs)" : <num>,
  ///      "durable timestamp queue lock internal thread time waiting (usecs)" : <num>,
  ///      "durable timestamp queue read lock acquisitions" : <num>,
  ///      "durable timestamp queue write lock acquisitions" : <num>,
  ///      "metadata lock acquisitions" : <num>,
  ///      "metadata lock application thread wait time (usecs)" : <num>,
  ///      "metadata lock internal thread wait time (usecs)" : <num>,
  ///      "read timestamp queue lock application thread time waiting (usecs)" : <num>,
  ///      "read timestamp queue lock internal thread time waiting (usecs)" : <num>,
  ///      "read timestamp queue read lock acquisitions" : <num>,
  ///      "read timestamp queue write lock acquisitions" : <num>,
  ///      "schema lock acquisitions" : <num>,
  ///      "schema lock application thread wait time (usecs)" : <num>,
  ///      "schema lock internal thread wait time (usecs)" : <num>,
  ///      "table lock application thread time waiting for the table lock (usecs)" : <num>,
  ///      "table lock internal thread time waiting for the table lock (usecs)" : <num>,
  ///      "table read lock acquisitions" : <num>,
  ///      "table write lock acquisitions" : <num>,
  ///      "txn global lock application thread time waiting (usecs)" : <num>,
  ///      "txn global lock internal thread time waiting (usecs)" : <num>,
  ///      "txn global read lock acquisitions" : <num>,
  ///      "txn global write lock acquisitions" : <num>
  ///   },
  ///   "log" : {
  ///      "busy returns attempting to switch slots" : <num>,
  ///      "force archive time sleeping (usecs)" : <num>,
  ///      "log bytes of payload data" : <num>,
  ///      "log bytes written" : <num>,
  ///      "log files manually zero-filled" : <num>,
  ///      "log flush operations" : <num>,
  ///      "log force write operations" : <num>,
  ///      "log force write operations skipped" : <num>,
  ///      "log records compressed" : <num>,
  ///      "log records not compressed" : <num>,
  ///      "log records too small to compress" : <num>,
  ///      "log release advances write LSN" : <num>,
  ///      "log scan operations" : <num>,
  ///      "log scan records requiring two reads" : <num>,
  ///      "log server thread advances write LSN" : <num>,
  ///      "log server thread write LSN walk skipped" : <num>,
  ///      "log sync operations" : <num>,
  ///      "log sync time duration (usecs)" : <num>,
  ///      "log sync_dir operations" : <num>,
  ///      "log sync_dir time duration (usecs)" : <num>,
  ///      "log write operations" : <num>,
  ///      "logging bytes consolidated" : <num>,
  ///      "maximum log file size" : <num>,
  ///      "number of pre-allocated log files to create" : <num>,
  ///      "pre-allocated log files not ready and missed" : <num>,
  ///      "pre-allocated log files prepared" : <num>,
  ///      "pre-allocated log files used" : <num>,
  ///      "records processed by log scan" : <num>,
  ///      "slot close lost race" : <num>,
  ///      "slot close unbuffered waits" : <num>,
  ///      "slot closures" : <num>,
  ///      "slot join atomic update races" : <num>,
  ///      "slot join calls atomic updates raced" : <num>,
  ///      "slot join calls did not yield" : <num>,
  ///      "slot join calls found active slot closed" : <num>,
  ///      "slot join calls slept" : <num>,
  ///      "slot join calls yielded" : <num>,
  ///      "slot join found active slot closed" : <num>,
  ///      "slot joins yield time (usecs)" : <num>,
  ///      "slot transitions unable to find free slot" : <num>,
  ///      "slot unbuffered writes" : <num>,
  ///      "total in-memory size of compressed records" : <num>,
  ///      "total log buffer size" : <num>,
  ///      "total size of compressed records" : <num>,
  ///      "written slots coalesced" : <num>,
  ///      "yields waiting for previous log file close" : <num>
  ///   },
  ///   "perf" : {
  ///      "file system read latency histogram (bucket 1) - 10-49ms" : <num>,
  ///      "file system read latency histogram (bucket 2) - 50-99ms" : <num>,
  ///      "file system read latency histogram (bucket 3) - 100-249ms" : <num>,
  ///      "file system read latency histogram (bucket 4) - 250-499ms" : <num>,
  ///      "file system read latency histogram (bucket 5) - 500-999ms" : <num>,
  ///      "file system read latency histogram (bucket 6) - 1000ms+" : <num>,
  ///      "file system write latency histogram (bucket 1) - 10-49ms" : <num>,
  ///      "file system write latency histogram (bucket 2) - 50-99ms" : <num>,
  ///      "file system write latency histogram (bucket 3) - 100-249ms" : <num>,
  ///      "file system write latency histogram (bucket 4) - 250-499ms" : <num>,
  ///      "file system write latency histogram (bucket 5) - 500-999ms" : <num>,
  ///      "file system write latency histogram (bucket 6) - 1000ms+" : <num>,
  ///      "operation read latency histogram (bucket 1) - 100-249us" : <num>,
  ///      "operation read latency histogram (bucket 2) - 250-499us" : <num>,
  ///      "operation read latency histogram (bucket 3) - 500-999us" : <num>,
  ///      "operation read latency histogram (bucket 4) - 1000-9999us" : <num>,
  ///      "operation read latency histogram (bucket 5) - 10000us+" : <num>,
  ///      "operation write latency histogram (bucket 1) - 100-249us" : <num>,
  ///      "operation write latency histogram (bucket 2) - 250-499us" : <num>,
  ///      "operation write latency histogram (bucket 3) - 500-999us" : <num>,
  ///      "operation write latency histogram (bucket 4) - 1000-9999us" : <num>,
  ///      "operation write latency histogram (bucket 5) - 10000us+" : <num>
  ///   },
  ///   "reconciliation" : {
  ///      "fast-path pages deleted" : <num>,
  ///      "page reconciliation calls" : <num>,
  ///      "page reconciliation calls for eviction" : <num>,
  ///      "pages deleted" : <num>,
  ///      "split bytes currently awaiting free" : <num>,
  ///      "split objects currently awaiting free" : <num>
  ///   },
  ///   "session" : {
  ///      "open session count" : <num>,
  ///      "session query timestamp calls" : <num>,
  ///      "table alter failed calls" : <num>,
  ///      "table alter successful calls" : <num>,
  ///      "table alter unchanged and skipped" : <num>,
  ///      "table compact failed calls" : <num>,
  ///      "table compact successful calls" : <num>,
  ///      "table create failed calls" : <num>,
  ///      "table create successful calls" : <num>,
  ///      "table drop failed calls" : <num>,
  ///      "table drop successful calls" : <num>,
  ///      "table import failed calls" : <num>,
  ///      "table import successful calls" : <num>,
  ///      "table rebalance failed calls" : <num>,
  ///      "table rebalance successful calls" : <num>,
  ///      "table rename failed calls" : <num>,
  ///      "table rename successful calls" : <num>,
  ///      "table salvage failed calls" : <num>,
  ///      "table salvage successful calls" : <num>,
  ///      "table truncate failed calls" : <num>,
  ///      "table truncate successful calls" : <num>,
  ///      "table verify failed calls" : <num>,
  ///      "table verify successful calls" : <num>
  ///   },
  ///   "thread-state" : {
  ///      "active filesystem fsync calls" : <num>,
  ///      "active filesystem read calls" : <num>,
  ///      "active filesystem write calls" : <num>
  ///   },
  ///   "thread-yield" : {
  ///      "application thread time evicting (usecs)" : <num>,
  ///      "application thread time waiting for cache (usecs)" : <num>,
  ///      "connection close blocked waiting for transaction state stabilization" : <num>,
  ///      "connection close yielded for lsm manager shutdown" : <num>,
  ///      "data handle lock yielded" : <num>,
  ///      "get reference for page index and slot time sleeping (usecs)" : <num>,
  ///      "log server sync yielded for log write" : <num>,
  ///      "page access yielded due to prepare state change" : <num>,
  ///      "page acquire busy blocked" : <num>,
  ///      "page acquire eviction blocked" : <num>,
  ///      "page acquire locked blocked" : <num>,
  ///      "page acquire read blocked" : <num>,
  ///      "page acquire time sleeping (usecs)" : <num>,
  ///      "page delete rollback time sleeping for state change (usecs)" : <num>,
  ///      "page reconciliation yielded due to child modification" : <num>
  ///   },
  ///   "transaction" : {
  ///      "Number of prepared updates" : <num>,
  ///      "Number of prepared updates added to cache overflow" : <num>,
  ///      "Number of prepared updates resolved" : <num>,
  ///      "durable timestamp queue entries walked" : <num>,
  ///      "durable timestamp queue insert to empty" : <num>,
  ///      "durable timestamp queue inserts to head" : <num>,
  ///      "durable timestamp queue inserts total" : <num>,
  ///      "durable timestamp queue length" : <num>,
  ///      "number of named snapshots created" : <num>,
  ///      "number of named snapshots dropped" : <num>,
  ///      "prepared transactions" : <num>,
  ///      "prepared transactions committed" : <num>,
  ///      "prepared transactions currently active" : <num>,
  ///      "prepared transactions rolled back" : <num>,
  ///      "query timestamp calls" : <num>,
  ///      "read timestamp queue entries walked" : <num>,
  ///      "read timestamp queue insert to empty" : <num>,
  ///      "read timestamp queue inserts to head" : <num>,
  ///      "read timestamp queue inserts total" : <num>,
  ///      "read timestamp queue length" : <num>,
  ///      "rollback to stable calls" : <num>,
  ///      "rollback to stable updates aborted" : <num>,
  ///      "rollback to stable updates removed from cache overflow" : <num>,
  ///      "set timestamp calls" : <num>,
  ///      "set timestamp durable calls" : <num>,
  ///      "set timestamp durable updates" : <num>,
  ///      "set timestamp oldest calls" : <num>,
  ///      "set timestamp oldest updates" : <num>,
  ///      "set timestamp stable calls" : <num>,
  ///      "set timestamp stable updates" : <num>,
  ///      "transaction begins" : <num>,
  ///      "transaction checkpoint currently running" : <num>,
  ///      "transaction checkpoint generation" : <num>,
  ///      "transaction checkpoint max time (msecs)" : <num>,
  ///      "transaction checkpoint min time (msecs)" : <num>,
  ///      "transaction checkpoint most recent time (msecs)" : <num>,
  ///      "transaction checkpoint scrub dirty target" : <num>,
  ///      "transaction checkpoint scrub time (msecs)" : <num>,
  ///      "transaction checkpoint total time (msecs)" : <num>,
  ///      "transaction checkpoints" : <num>,
  ///      "transaction checkpoints skipped because database was clean" : <num>,
  ///      "transaction failures due to cache overflow" : <num>,
  ///      "transaction fsync calls for checkpoint after allocating the transaction ID" : <num>,
  ///      "transaction fsync duration for checkpoint after allocating the transaction ID (usecs)" : <num>,
  ///      "transaction range of IDs currently pinned" : <num>,
  ///      "transaction range of IDs currently pinned by a checkpoint" : <num>,
  ///      "transaction range of IDs currently pinned by named snapshots" : <num>,
  ///      "transaction range of timestamps currently pinned" : <num>,
  ///      "transaction range of timestamps pinned by a checkpoint" : <num>,
  ///      "transaction range of timestamps pinned by the oldest active read timestamp" : <num>,
  ///      "transaction range of timestamps pinned by the oldest timestamp" : <num>,
  ///      "transaction read timestamp of the oldest active reader" : <num>,
  ///      "transaction sync calls" : <num>,
  ///      "transactions committed" : <num>,
  ///      "transactions rolled back" : <num>,
  ///      "update conflicts" : <num>
  ///   },
  ///   "concurrentTransactions" : {
  ///      "write" : {
  ///         "out" : <num>,
  ///         "available" : <num>,
  ///         "totalTickets" : <num>
  ///      },
  ///      "read" : {
  ///         "out" : <num>,
  ///         "available" : <num>,
  ///         "totalTickets" : <num>
  ///      }
  ///   },
  ///   "snapshot-window-settings" : {
  ///      "cache pressure percentage threshold" : <num>,
  ///      "current cache pressure percentage" : <num>,
  ///      "total number of SnapshotTooOld errors" : <num>,
  ///      "max target available snapshots window size in seconds" : <num>,
  ///      "target available snapshots window size in seconds" : <num>,
  ///      "current available snapshots window size in seconds" : <num>,
  ///      "latest majority snapshot timestamp available" : <string>,
  ///      "oldest majority snapshot timestamp available" : <string>
  ///   }
  /// }
  Map<String, dynamic> wiredTiger;

  // **** Write Backs Queued ****
  /// A boolean that indicates whether there are operations from a mongos
  /// instance queued for retrying. Typically, this value is false.
  /// See also writeBacks.
  ///
  /// "writeBacksQueued" : <boolean>,
  bool writeBacksQueued;

  // **** Mem ****
  /// A document that reports on the system architecture of the mongod and
  /// current memory use.
  ///
  /// "mem" : {
  ///   "bits" : <int>,
  ///   "resident" : <int>,
  ///   "virtual" : <int>,
  ///   "supported" : <boolean>,
  ///   "mapped" : <int>,
  ///   "mappedWithJournal" : <int>
  /// },
  Map<String, dynamic> mem;

  // **** Metrics ****
  /// A document that returns various statistics that reflect the current
  /// use and state of a running mongod instance.
  ///
  /// "metrics" : {
  ///   "aggStageCounters" : {
  ///         "<aggregation stage>" : <num>
  ///         }
  ///   },
  ///   "commands": {
  ///         "<command>": {
  ///            "failed": <num>,
  ///            "total": <num>
  ///         }
  ///   },
  ///   "cursor" : {
  ///         "timedOut" : NumberLong(<num>),
  ///         "open" : {
  ///            "noTimeout" : NumberLong(<num>),
  ///            "pinned" : NumberLong(<num>),
  ///            "multiTarget" : NumberLong(<num>),
  ///            "singleTarget" : NumberLong(<num>),
  ///            "total" : NumberLong(<num>),
  ///         }
  ///   },
  ///   "document" : {
  ///         "deleted" : NumberLong(<num>),
  ///         "inserted" : NumberLong(<num>),
  ///         "returned" : NumberLong(<num>),
  ///         "updated" : NumberLong(<num>)
  ///   },
  ///   "getLastError" : {
  ///         "wtime" : {
  ///            "num" : <num>,
  ///            "totalMillis" : <num>
  ///         },
  ///         "wtimeouts" : NumberLong(<num>),
  ///         "default" : {
  ///             "unsatisfiable" : <num>
  ///             "wtimeouts" : <num>
  ///         }
  ///   },
  ///   "operation" : {
  ///         "scanAndOrder" : NumberLong(<num>),
  ///         "writeConflicts" : NumberLong(<num>)
  ///   },
  ///   "queryExecutor": {
  ///         "scanned" : NumberLong(<num>),
  ///         "scannedObjects" : NumberLong(<num>),
  ///         "collectionScans" : {
  ///             "nonTailable" : NumbeLong(<num>),
  ///             "total" : NumberLong(<num>)
  ///         }
  ///   },
  ///   "record" : {
  ///         "moves" : NumberLong(<num>)
  ///   },
  ///   "repl" : {
  ///      "executor" : {
  ///         "pool" : {
  ///            "inProgressCount" : <num>
  ///         },
  ///         "queues" : {
  ///            "networkInProgress" : <num>,
  ///            "sleepers" : <num>
  ///         },
  ///         "unsignaledEvents" : <num>,
  ///         "shuttingDown" : <boolean>,
  ///         "networkInterface" : <string>
  ///      },
  ///      "apply" : {
  ///         "attemptsToBecomeSecondary" : <NumberLong>,
  ///         "batches" : {
  ///            "num" : <num>,
  ///            "totalMillis" : <num>
  ///         },
  ///         "ops" : <NumberLong>
  ///      },
  ///      "buffer" : {
  ///         "count" : <NumberLong>,
  ///         "maxSizeBytes" : <NumberLong>,
  ///         "sizeBytes" : <NumberLong>
  ///      },
  ///      "initialSync" : {
  ///         "completed" : <NumberLong>,
  ///         "failedAttempts" : <NumberLong>,
  ///         "failures" : <NumberLong>,
  ///      },
  ///      "network" : {
  ///         "bytes" : <NumberLong>,
  ///         "getmores" : {
  ///            "num" : <num>,
  ///            "totalMillis" : <num>
  ///         },
  ///         "notMasterLegacyUnacknowledgedWrites" : <NumberLong>,
  ///         "notMasterUnacknowledgedWrites" : <NumberLong>,
  ///         "oplogGetMoresProcessed" : {
  ///            "num" : <NumberLong>,
  ///            "totalMillis" : <NumberLong>
  ///         },
  ///         "ops" : <NumberLong>,
  ///         "readersCreated" : <NumberLong>,
  ///         "replSetUpdatePosition" : {
  ///             "num" : <NumberLong>
  ///         }
  ///      },
  ///      "stepDown" : {
  ///         "userOperationsKilled" : <NumberLong>,
  ///         "userOperationsRunning" : <NumberLong>
  ///      },
  ///      "syncSource" : {
  ///         "numSelections" : <NumberLong>,
  ///         "numTimesChoseSame" : <NumberLong>,
  ///         "numTimesChoseDifferent" : <NumberLong>,
  ///         "numTimesCouldNotFind" : <NumberLong>
  ///      }
  ///   },
  ///   "storage" : {
  ///         "freelist" : {
  ///            "search" : {
  ///               "bucketExhausted" : <num>,
  ///               "requests" : <num>,
  ///               "scanned" : <num>
  ///            }
  ///         }
  ///   },
  ///   "ttl" : {
  ///         "deletedDocuments" : NumberLong(<num>),
  ///         "passes" : NumberLong(<num>)
  ///   }
  /// },
  Map<String, dynamic> metrics;

  // **** Watchdog ****
  /// A document reporting the status of the
  /// [Storage Node Watchdog](https://docs.mongodb.com/manual/administration/monitoring/#storage-node-watchdog).
  ///
  /// "watchdog" : {
  ///   "checkGeneration" : NumberLong(<num>),
  ///   "monitorGeneration" : NumberLong(<num>),
  ///   "monitorPeriod" : <num>
  /// }
  Map<String, dynamic> watchdog;

  void extractInstanceInfo(Map<String, dynamic> document) {
    host = document[keyHost];
    advisoryHostFQDNs = document[keyAdvisoryHostFQDNs];
    version = document[keyVersion];
    process = document[keyProcess];
    pid = document[keyPid];
    if (document[keyUptime] is double) {
      uptime = (document[keyUptime] as double).toInt();
    } else {
      uptime = document[keyUptime];
    }
    uptimeMillis = document[keyUptimeMillis];
    uptimeEstimate = document[keyUptimeEstimate];
    localTime = document[keyLocalTime];
  }
}
