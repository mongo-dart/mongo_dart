import 'package:bson/bson.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Basic communication from a MongoDb server
///
/// returns the following fields:
/// `operationTime` => @Since 3.6 - The logical time of the performed operation,
///    represented in MongoDB by the timestamp from the oplog entry.
///    *Only for replica sets and sharded clusters*
///    If the command does not generate an oplog entry,
///    e.g. a read operation, then the operation does not advance
///    the logical clock. In this case, operationTime returns:
///    * For read concern "local", the timestamp of the most recent entry
///      in the oplog.
///    * For read concern "majority" and "linearizable", the timestamp of
///      the most recent majority-acknowledged entry in the oplog.
///    * For operations associated with causally consistent sessions,
///      MongoDB drivers use this time to automatically set the
///      Read Operations and afterClusterTime.
/// `$clusterTime` => @Since 3.6 - a [$ClusterTime] object

mixin TimingResult {
  DateTime operationTime;
  $ClusterTime $clusterTime;

  void extractTiming(Map<String, Object> document) {
    document ??= <String, Object>{};
    var opTime = document[keyOperationTime];
    if (opTime is Timestamp) {
      operationTime =
          DateTime.fromMillisecondsSinceEpoch(opTime.seconds * 1000);
    } else if (opTime is DateTime) {
      operationTime = document[keyOperationTime];
    }

    $clusterTime = $ClusterTime(document);
  }
}

/// A document that contains the hash of the cluster time
/// and the id of the key used to sign the cluster time.
class Signature {
  BsonBinary hash;
  int keyId;

  Signature(Map<String, Object> document) {
    _extract(document);
  }

  void _extract(Map<String, Object> document) {
    document ??= <String, Object>{};
    keyId = document[keyKeyId];
    hash = document[keyHash];
  }
}

/// A document that returns the signed cluster time.
///
/// Cluster time is a logical time used for ordering of operations.
/// *Only for replica sets and sharded clusters.* **For internal use only**
/// The document contains the following fields:
/// `clusterTime` => timestamp of the highest known cluster time for the member.
/// `signature`: => a [Signature] object
class $ClusterTime {
  DateTime clusterTime;
  Signature signature;

  $ClusterTime(Map<String, Object> document) {
    _extract(document);
  }

  void _extract(Map<String, Object> document) {
    document ??= <String, Object>{};
    clusterTime = document[keyClusterTime];
    signature = Signature(document);
  }
}
