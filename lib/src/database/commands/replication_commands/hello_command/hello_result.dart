import 'package:bson/bson.dart';
import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Class representing the output of the Hello command
/// Not all values are represented. If you need something that here is missing
/// use the execute method that returns the original Map document.
///
/// **Note**
/// hello returns a document that describes the role of the mongod instance.
/// If the optional field saslSupportedMechs is specified, the command also
/// returns an array of SASL mechanisms used to create the specified
/// user's credentials.
/// If the instance is a member of a replica set, then hello returns a
/// subset of the replica set configuration and status including whether or
/// not the instance is the primary of the replica set.
/// When sent to a mongod instance that is not a member of a replica set,
/// hello returns a subset of this information.
/// MongoDB drivers and clients use hello to determine the state of the
/// replica set members and to discover additional members of a replica set.

class HelloResult with BasicResult {
  HelloResult(Map<String, Object?> document)
      : isWritablePrimary = document[keyIsWritablePrimary] as bool? ?? false,
        maxBsonObjectSize =
            document[keyMaxBsonObjectSize] as int? ?? 16 * 1024 * 1024,
        maxMessageSizeBytes =
            document[keyMaxMessageSizeBytes] as int? ?? 48000000,
        maxWriteBatchSize = document[keyMaxWriteBatchSize] as int? ?? 100000,
        localTime = document[keyLocalTime] as DateTime,
        logicalSessionTimeoutMinutes =
            document[keyLogicalSessionTimeoutMinutes] as int,
        minWireVersion = document[keyMinWireVersion] as int,
        maxWireVersion = document[keyMaxWireVersion] as int,
        readOnly = document[keyReadOnly] as bool? ?? false {
    extractBasic(document);

    topologyVersion = document[keyTopologyVersion];
    connectionId = document[keyConnectionId] as int?;
    compression = document[keyCompression] as List<String>?;
    saslSupportedMechs = document.containsKey(keySaslSupportedMechs)
        ? <String>[...?(document[keySaslSupportedMechs] as List?)]
        : null;

    // Sharded
    msg = document[keyMsg] as String?;

    // Replica set
    hosts = document.containsKey(keyHosts)
        ? <String>[...?(document[keyHosts] as List?)]
        : null;
    setName = document[keySetName] as String?;
    setVersion = document[keySetVersion] as int?;
    secondary = document[keySecondary] as bool?;
    passives = document.containsKey(keyPassives)
        ? <String>[...?(document[keyPassives] as List?)]
        : null;
    arbiters = document.containsKey(keyArbiters)
        ? <String>[...?(document[keyArbiters] as List?)]
        : null;
    primary = document[keyPrimary] as String?;
    arbiterOnly = document[keyArbiterOnly] as bool?;
    passive = document[keyPassive] as bool?;
    hidden = document[keyHidden] as bool?;
    tags = document.containsKey(keyTags)
        ? <String, String>{...?(document[keyTags] as Map?)}
        : null;
    me = document[keyMe] as String?;
    electionId = document[keyElectionId] as ObjectId?;
    lastWrite = document[keyLastWrite] as Map?;
  }

  // ***** INSTANCE INFORMATION ******
  /// A boolean value that reports when this node is writable.
  /// If true, then this instance is a primary in a replica set,
  /// or a mongos instance, or a standalone mongod.
  ///  This field will be false if the instance is a secondary member of a
  /// replica set or if the member is an arbiter of a replica set.
  bool isWritablePrimary;

  /// **_For internal use by MongoDB._**
  dynamic topologyVersion;

  /// The maximum permitted size of a BSON object in bytes for this mongod
  ///  process. If not provided, clients should assume a max size
  /// of "16 * 1024 * 1024".
  int maxBsonObjectSize;

  /// The maximum permitted size of a BSON wire protocol message.
  /// The default value is 48000000 bytes.
  int maxMessageSizeBytes;

  /// The maximum number of write operations permitted in a write batch.
  /// If a batch exceeds this limit, the client driver divides the batch
  /// into smaller groups each with counts less than or equal to the value
  /// of this field.
  /// The value of this limit is 100,000 writes.
  int maxWriteBatchSize;

  /// Returns the local server time in UTC.
  DateTime localTime;

  /// The time in minutes that a session remains active after its most
  /// recent use. Sessions that have not received a new read/write operation
  /// from the client or been refreshed with refreshSessions within this
  ///  threshold are cleared from the cache. State associated with an expired
  /// session may be cleaned up by the server at any time.
  int logicalSessionTimeoutMinutes;

  /// An identifier for the mongod/mongos instance's outgoing
  /// connection to the client.
  int? connectionId;

  /// The earliest version of the wire protocol that this mongod or mongos
  ///  instance is capable of using to communicate with clients.
  /// Clients may use minWireVersion to help negotiate compatibility
  /// with MongoDB.
  int minWireVersion;

  /// The latest version of the wire protocol that this mongod or mongos
  /// instance is capable of using to communicate with clients.
  ///  Clients may use maxWireVersion to help negotiate compatibility
  /// with MongoDB.
  int maxWireVersion;

  /// A boolean value that, when true, indicates that the mongod or mongos
  ///  is running in read-only mode.
  bool readOnly;

  /// An array listing the compression algorithms used or available for use
  /// (i.e. common to both the client and the mongod or mongos instance)
  /// to compress the communication between the client and the mongod
  /// or mongos instance.
  /// The field is only available if compression is used. For example:
  ///  If the mongod is enabled to use both the snappy,zlib compressors
  /// and a client has specified zlib, the compression field would contain:
  ///  "compression": [ "zlib" ]
  /// If the mongod is enabled to use both the snappy,zlib compressors and
  /// a client has specified zlib,snappy, the compression field would contain:
  ///   "compression": [ "zlib", "snappy" ]
  /// If the mongod is enabled to use the snappy compressor and a client
  /// has specified zlib,snappy, the compression field would contain :
  ///  "compression": [ "snappy" ]
  /// If the mongod is enabled to use the snappy compressor and a client has s
  /// pecified zlib or the client has specified no compressor,
  /// the field is omitted.
  /// That is, if the client does not specify compression or if the client
  /// specifies a compressor not enabled for the connected mongod or
  /// mongos instance, the field does not return.
  List<String>? compression;

  /// An array of SASL mechanisms used to create the user's credential or
  ///  credentials. Supported SASL mechanisms are:
  /// - GSSAPI
  /// - SCRAM-SHA-256
  /// - SCRAM-SHA-1
  /// The field is returned only when the command is run with the saslSupportedMechs field:
  /// `db.runCommand( { hello: 1, saslSupportedMechs: "<db.username>" } )`
  List<String>? saslSupportedMechs;

  /// *** Sharded Instances
  ///   mongos instances add the following field to the hello response document:

  /// Contains the value isdbgrid when hello returns from a mongos instance.
  String? msg;

  /// *** Replica Sets
  ///  hello contains these fields when returned by a member of a replica set:

  /// An array of strings in the format of "[hostname]:[port]" that lists all
  /// members of the replica set that are neither hidden, passive, nor arbiters.
  /// Drivers use this array and the hello.passives to determine which
  /// members to read from.
  List<String>? hosts;

  /// The name of the current :replica set.
  String? setName;

  /// The current replica set config version.
  int? setVersion;

  /// A boolean value that, when true, indicates if the mongod is a
  /// secondary member of a replica set.
  bool? secondary;

  /// An array of strings in the format of "[hostname]:[port]" listing
  /// all members of the replica set which have a members[n].priority of 0.
  /// This field only appears if there is at least one member with a
  /// members[n].priority of 0.
  /// Drivers use this array and the hello.hosts to determine which members
  /// to read from.
  List<String>? passives;

  /// An array of strings in the format of "[hostname]:[port]" listing all
  /// members of the replica set that are arbiters.
  /// This field only appears if there is at least one arbiter in the
  /// replica set.
  List<String>? arbiters;

  /// A string in the format of "[hostname]:[port]" listing the
  /// current primary member of the replica set.
  String? primary;

  /// A boolean value that , when true, indicates that the current instance
  /// is an arbiter. The arbiterOnly field is only present,
  /// if the instance is an arbiter.
  bool? arbiterOnly;

  /// A boolean value that, when true, indicates that the current instance
  /// is passive. The passive field is only present for members with a
  /// members[n].priority of 0.
  bool? passive;

  /// A boolean value that, when true, indicates that the current instance
  /// is hidden. The hidden field is only present for hidden members.
  bool? hidden;

  /// A tags document contains user-defined tag field and value pairs
  /// for the replica set member.
  /// `{ "<tag1>": "<string1>", "<tag2>": "<string2>",... }`
  /// For read operations, you can specify a tag set in the read preference
  /// to direct the operations to replica set member(s) with the
  /// specified tag(s).
  /// For write operations, you can create a customize write concern using
  /// settings.getLastErrorModes and settings.getLastErrorDefaults.
  /// For more information, see [Configure Replica Set Tag Sets]
  /// (https://docs.mongodb.com/v5.0/tutorial/configure-replica-set-tag-sets/).
  Map<String, String>? tags;

  /// The [hostname]:[port] of the member that returned hello.
  String? me;

  /// A unique identifier for each election. Included only in the output
  /// of hello for the primary. Used by clients to determine
  /// when elections occur.
  ObjectId? electionId;

  /// A document containing optime and date information for the database's
  /// most recent write operation.
  /// - hello.lastWrite.opTime
  ///   An object giving the optime of the last write operation.
  /// - hello.lastWrite.lastWriteDate
  ///   A date object containing the time of the last write operation.
  /// - hello.lastWrite.majorityOpTime
  ///   An object giving the optime of the last write operation readable by majority reads.
  /// - hello.lastWrite.majorityWriteDate
  ///   A date object containing the time of the last write operation readable by majority reads.
  ///
  /// For details on the ok status field, the operationTime field, and the
  /// $clusterTime field, see Command Response.
  Map? lastWrite;
}
