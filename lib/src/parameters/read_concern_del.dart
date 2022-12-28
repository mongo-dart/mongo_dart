/* /// Read Concern Levels
/// The following read concern levels are available:

/// | Level | Description |
/// | :---: | :--- |
/// | "local" | The query returns data from the instance with no guarantee that the data has been written to a majority of the replica set members (i.e. may be rolled back). Default for reads against the primary and secondaries. Availability: Read concern "local" is available for use with or without causally consistent sessions and transactions. For more information, see the "local" reference page.|
/// |"available"| The query returns data from the instance with no guarantee that the data has been written to a majority of the replica set members (i.e. may be rolled back). Availability: Read concern "available" is unavailable for use with causally consistent sessions and transactions. For sharded clusters, "available" read concern provides the lowest latency reads possible among the various read concerns. However, this comes at the expense of consistency as "available" read concern can return orphaned documents when reading from a sharded collection. To avoid the risk of returning orphaned documents when reading from sharded collections, use a different read concern such as read concern "local". For more information, see the "available" reference page. |
/// |"majority"| The query returns the data that has been acknowledged by a majority of the replica set members. The documents returned by the read operation are durable, even in the event of failure. To fulfill read concern "majority", the replica set member returns data from its in-memory view of the data at the majority-commit point. As such, read concern "majority" is comparable in performance cost to other read concerns. Availability: Read concern "majority" is available for use with or without causally consistent sessions and transactions. Requirements: To use read concern level of "majority", replica sets must use WiredTiger storage engine. NOTE For operations in multi-document transactions, read concern "majority" provides its guarantees only if the transaction commits with write concern "majority". Otherwise, the "majority" read concern provides no guarantees about the data read in transactions. For more information, see the "majority" reference page.|
/// |"linearizable"| The query returns data that reflects all successful majority-acknowledged writes that completed prior to the start of the read operation. The query may wait for concurrently executing writes to propagate to a majority of replica set members before returning results. If a majority of your replica set members crash and restart after the read operation, documents returned by the read operation are durable if writeConcernMajorityJournalDefault is set to the default state of true. With writeConcernMajorityJournalDefault set to false, MongoDB does not wait for w: "majority" writes to be written to the on-disk journal before acknowledging the writes. As such, "majority" write operations could possibly roll back in the event of a transient loss (e.g. crash and restart) of a majority of nodes in a given replica set. Availability: Read concern "linearizable" is unavailable for use with causally consistent sessions and transactions. You can specify linearizable read concern for read operations on the primary only. You cannot use the $out or the $merge stage in conjunction with read concern "linearizable". That is, if you specify "linearizable" read concern for db.collection.aggregate(), you cannot include either stages in the pipeline. Requirements: Linearizable read concern guarantees only apply if read operations specify a query filter that uniquely identifies a single document. TIP Always use maxTimeMS with linearizable read concern in case a majority of data bearing members are unavailable. maxTimeMS ensures that the operation does not block indefinitely and instead ensures that the operation returns an error if the read concern cannot be fulfilled. For more information, see the "linearizable" reference page.|
/// |"snapshot"| If a transaction is not part of a causally consistent session, upon transaction commit with write concern "majority", the transaction operations are guaranteed to have read from a snapshot of majority-committed data. If a transaction is part of a causally consistent session, upon transaction commit with write concern "majority", the transaction operations are guaranteed to have read from a snapshot of majority-committed data that provides causal consistency with the operation immediately preceding the transaction start. Availability: Read concern "snapshot" is available for All read operations inside multi-document transactions with the read concern set at the transaction level. The following methods outside of multi-document transactions: find aggregate distinct (on unsharded collections) All other read operations prohibit "snapshot".||
/// | | |
/// | | Regardless of the read concern level, the most recent data on a node may not reflect the most recent version of the data in the system. |

/// | | For more information on each read concern level, see: |
/// | | Read Concern "local"|
/// | | Read Concern "available"|
/// | | Read Concern "majority"|
/// | | Read Concern "linearizable"|
/// | | Read Concern "snapshot"|
/// | | Default MongoDB Read Concerns/Write Concerns|

enum ReadConcernLevel { local, available, majority, linearizable, snapshot }

class ReadConcern {
  ReadConcernLevel level;

  ReadConcern(this.level);

  ReadConcern.fromString(String levelString)
      : level = ReadConcernLevel.values.byName(levelString);
}
 */
