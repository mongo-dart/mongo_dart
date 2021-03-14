import 'package:mongo_dart/src/database/utils/map_keys.dart';

enum ReadConcernLevel {
  /// A query with read concern "local" returns data from the instance
  /// with no guarantee that the data has been written to a majority
  /// of the replica set members (i.e. may be rolled back).
  /// Read concern "local" is the default for:
  /// * read operations against primary
  /// * read operations against secondaries if the reads are associated
  ///   with causally consistent sessions.
  /// Regardless of the read concern level, the most recent data on a node may
  /// not reflect the most recent version of the data in the system.
  /// ## Availability
  /// Read concern local is available for use with or without causally
  /// consistent sessions and transactions.
  /// [See] (https://docs.mongodb.com/manual/reference/read-concern-local/)
  local,

  /// @Since(3.6)
  /// A query with read concern “available” returns data from the
  /// instance with no guarantee that the data has been written to a
  /// majority of the replica set members (i.e. may be rolled back).
  /// Read concern “available” is the default for reads against
  /// secondaries if the reads are not associated with causally
  /// consistent sessions.
  /// For a sharded cluster, "available" read concern provides greater
  /// tolerance for partitions since it does not wait to ensure consistency
  /// guarantees. That is, read concern "available" does not contact the
  /// shard’s primary nor the config servers for updated metadata.
  /// However, this means that a query with "available" read concern may
  /// return orphaned documents if the shard is undergoing chunk migrations.
  /// For unsharded collections (including collections in a standalone
  /// deployment or a replica set deployment), "local" and "available"
  /// read concerns behave identically.
  /// Regardless of the read concern level, the most recent data on a node
  /// may not reflect the most recent version of the data in the system.
  /// See also
  /// [orphanCleanupDelaySecs](https://docs.mongodb.com/manual/reference/parameters/#param.orphanCleanupDelaySecs)
  /// ##Availability
  /// Read concern available is unavailable for use with causally
  /// consistent sessions and transactions.
  /// [See](https://docs.mongodb.com/manual/reference/read-concern-available/)
  available,

  /// The query returns the data that has been acknowledged by a majority
  /// of the replica set members. The documents returned by the read
  /// operation are durable, even in the event of failure.
  /// To fulfill read concern “majority”, the replica set member returns
  /// data from its in-memory view of the data at the majority-commit
  /// point. As such, read concern "majority" is comparable in performance
  /// cost to other read concerns.
  /// ##Availability:
  /// Read concern "majority" is available for use with or without causally
  /// consistent sessions and transactions.
  ///
  /// You can disable read concern "majority" for a deployment with a
  /// three-member primary-secondary-arbiter (PSA) architecture;
  /// however, this has implications for change streams
  /// (in MongoDB 4.0 and earlier only) and transactions on
  /// sharded clusters. For more information, see
  /// [Disable Read Concern Majority](https://docs.mongodb.com/manual/reference/read-concern-majority/#disable-read-concern-majority).
  /// **Requirements**: To use read concern level of "majority",
  /// replica sets must use WiredTiger storage engine.
  /// ## Note
  /// For operations in multi-document transactions, read concern "majority" provides its guarantees only if the transaction commits with write concern “majority”. Otherwise, the "majority" read concern provides no guarantees about the data read in transactions.
  /// [See](https://docs.mongodb.com/manual/reference/read-concern-majority/)
  majority,

  /// The query returns data that reflects all successful majority-acknowledged
  /// writes that completed prior to the start of the read operation.
  /// The query may wait for concurrently executing writes to propagate
  /// to a majority of replica set members before returning results.
  /// If a majority of your replica set members crash and restart after
  /// the read operation, documents returned by the read operation are durable
  /// if writeConcernMajorityJournalDefault is set to the default state of true.
  /// With writeConcernMajorityJournalDefault set to false, MongoDB does
  /// not wait for w: "majority" writes to be written to the on-disk journal
  /// before acknowledging the writes. As such, majority write operations
  /// could possibly roll back in the event of a transient loss
  /// (e.g. crash and restart) of a majority of nodes in a given replica set.
  /// ##Availability:
  /// Read concern "linearizable" is unavailable for use with causally
  /// consistent sessions and transactions.
  ///  You can specify linearizable read concern for read operations on
  /// the primary only.
  /// You cannot use the $out or the $merge stage in conjunction with read
  /// concern "linearizable". That is, if you specify "linearizable" read
  /// concern for db.collection.aggregate(), you cannot include either
  /// stages in the pipeline.
  /// **Requirements**: Linearizable read concern guarantees only apply if
  /// read operations specify a query filter that uniquely identifies a
  /// single document.
  /// ##Tip
  /// Always use maxTimeMS with linearizable read concern in case a majority
  /// of data bearing members are unavailable. maxTimeMS ensures that the
  /// operation does not block indefinitely and instead ensures that the
  /// operation returns an error if the read concern cannot be fulfilled.
  /// [See](https://docs.mongodb.com/manual/reference/read-concern-linearizable/)
  linearizable,

  /// If the transaction is not part of a causally consistent session, upon
  /// transaction commit with write concern "majority", the transaction
  /// operations are guaranteed to have read from a snapshot of
  /// majority-committed data.
  /// If the transaction is part of a causally consistent session, upon
  /// transaction commit with write concern "majority", the transaction
  /// operations are guaranteed to have read from a snapshot of
  /// majority-committed data that provides causal consistency with the
  /// operation immediately preceding the transaction start.
  /// ##Availability:
  /// Read concern "snapshot" is only available for use with multi-document
  /// transactions.
  /// For transactions on a sharded cluster, if any operation in the
  /// transaction involves a shard that has disabled read concern “majority”,
  /// you cannot use read concern "snapshot" for the transaction.
  /// You can only use read concern "local" or "majority" for the transaction.
  /// [See](https://docs.mongodb.com/manual/reference/read-concern-snapshot/)
  snapshot
}

/// The readConcern option allows you to control the consistency and isolation
/// properties of the data read from replica sets and replica set shards.
///
/// MongoDB drivers updated for MongoDB 3.2 or later support specifying
/// read concern.
/// Starting in MongoDB 4.4, replica sets and sharded clusters support
/// setting a global default read concern.
/// Operations which do not specify an explicit read concern inherit
/// the global default read concern settings.
/// See [setDefaultRWConcern](https://docs.mongodb.com/manual/reference/command/setDefaultRWConcern/#dbcmd.setDefaultRWConcern)
/// for more information.
///
/// see https://docs.mongodb.com/manual/reference/read-concern/
class ReadConcern {
  ReadConcern(this.level);
  ReadConcernLevel level;

  Map<String, Object> toMap() =>
      <String, Object>{if (level != null) keyLevel: '$level'.split('.').last};
}
