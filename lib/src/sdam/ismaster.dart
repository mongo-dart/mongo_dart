class Ismaster {
  // A boolean value that reports when this node is writable.
  // If true, then this instance is a primary in a replica set,
  // or a mongos instance, or a standalone mongod.
  bool ismaster;
  // @since('4.4')
  // For internal use by MongoDB.
  dynamic topologyVersion;
  int maxBsonObjectSize = 16 * 1024 * 1024;
  int maxMessageSizeBytes = 48000000;
  int maxWriteBatchSize = 100000;
  // Todo check how ISODate representation is
  dynamic localTime;
  // since('3.6')
  // The time in minutes that a session remains active
  // after its most recent use.
  int logicalSessionTimeoutMinutes;
  // since('4.2')
  // An identifier for the mongod/mongos instance’s outgoing connection to the client
  dynamic connectionId;
  int minWireVersion = 0;
  int maxWireVersion = 0;
  // A boolean value that, when true,
  // indicates that the mongod or mongos is running in read-only mode
  bool readOnly = false;
  // An array listing the compression algorithms used or available for use
  // (i.e. common to both the client and the mongod or mongos instance)
  // to compress the communication between the client
  // and the mongod or mongos instance.
  List<String> compression;
  // An array of SASL mechanisms used to create the user’s credential or
  //credentials. Supported SASL mechanisms are:
  // - GSSAPI
  // - SCRAM-SHA-256
  // - SCRAM-SHA-1
  List<String> saslSupportedMechs;

  // *** Mongos added
  //Contains the value isdbgrid when isMaster returns from a mongos instance.
  dynamic msg;

  // *** Replica Set fields
  // An array of strings in the format of "[hostname]:[port]" that lists
  // all members of the replica set that are neither hidden, passive, nor arbiters.
  List hosts = [];
  // Name of the replica set
  String setName;
  // The current replica set config version.
  dynamic setVersion;
  // A bool value that, when true, indicates if the mongod is a secondary
  // member of a replica set.
  bool secondary;
  // An array of strings in the format of "[hostname]:[port]" listing all
  // members of the replica set which have a members[n].priority of 0.
  List<String> passives = <String>[];
  // An array of strings in the format of "[hostname]:[port]" listing all
  // members of the replica set that are arbiters.
  List<String> arbiters = <String>[];
  // A string in the format of "[hostname]:[port]" listing the current
  // primary member of the replica set.
  String primary;
  // A bool value that , when true, indicates that the current instance
  // is an arbiter. The arbiterOnly field is only present,
  // if the instance is an arbiter.
  bool arbiterOnly = false;
  // A boolean value that, when true, indicates that the current instance
  // is passive. The passive field is only present for members with a
  // members[n].priority of 0.
  bool passive;
  // A boolean value that, when true, indicates that the current instance
  // is hidden. The hidden field is only present for hidden members.
  bool hidden;
  // A tags document contains user-defined tag field and value pairs
  // for the replica set member.
  Map<String, String> tags = <String, String>{};
  // The [hostname]:[port] of the member that returned isMaster.
  String me;
  // A unique identifier for each election. Included only in the output of
  // isMaster for the primary.
  // Used by clients to determine when elections occur.
  dynamic electionId;
  // A document containing optime and date information for the database’s
  // most recent write operation.
  // lastWrite.opTime - An object giving the optime of the last write operation.
  // lastWrite.lastWriteDate - A date object containing the time of the
  //     last write operation.
  // lastWrite.majorityOpTime - An object giving the optime of the
  //     last write operation readable by majority reads.
  // lastWrite.majorityWriteDate - A date object containing the time of the
  //     last write operation readable by majority reads.
  Map lastWrite;

  // Originally was "__nodejs_mock_server__"
  dynamic dart_mock_server;
  dynamic $clusterTime;

  Ismaster();

  List<String> get servers => [...hosts, ...arbiters, ...passives];

  Ismaster.fromMap(Map<String, dynamic> ismaster) {
    for (var key in ismaster.keys) {
      switch (key) {
        case 'minWireVersion':
          minWireVersion = ismaster['minWireVersion'];
          break;
        case 'maxWireVersion':
          maxWireVersion = ismaster['maxWireVersion'];
          break;
        case 'maxBsonObjectSize':
          maxBsonObjectSize = ismaster['maxBsonObjectSize'];
          break;
        case 'maxMessageSizeBytes':
          maxMessageSizeBytes = ismaster['maxMessageSizeBytes'];
          break;
        case 'maxWriteBatchSize':
          maxWriteBatchSize = ismaster['maxWriteBatchSize'];
          break;
        case 'compression':
          compression = ismaster['compression'];
          break;
        case 'me':
          me = ismaster['me'];
          break;
        case 'hosts':
          hosts = ismaster['hosts'];
          break;
        case 'passives':
          passives = ismaster['passives'];
          break;
        case 'arbiters':
          arbiters = ismaster['arbiters'];
          break;
        case 'tags':
          tags = ismaster['tags'];
          break;
        case 'setName':
          setName = ismaster['setName'];
          break;
        case 'setVersion':
          setVersion = ismaster['setVersion'];
          break;
        case 'electionId':
          electionId = ismaster['electionId'];
          break;
        case 'primary':
          primary = ismaster['primary'];
          break;
        case 'logicalSessionTimeoutMinutes':
          logicalSessionTimeoutMinutes =
              ismaster['logicalSessionTimeoutMinutes'];
          break;
        case 'saslSupportedMechs':
          saslSupportedMechs = ismaster['saslSupportedMechs'];
          break;
        case 'dart_mock_server':
          dart_mock_server = ismaster['dart_mock_server'];
          break;
        case r'$clusterTime':
          $clusterTime = ismaster[r'$clusterTime'];
          break;
      }
    }
  }

  Ismaster duplicate() {
    return Ismaster()
      ..minWireVersion = minWireVersion
      ..maxWireVersion = maxWireVersion
      ..maxBsonObjectSize = maxBsonObjectSize
      ..maxMessageSizeBytes = maxMessageSizeBytes
      ..maxWriteBatchSize = maxWriteBatchSize
      ..compression = compression
      ..me = me
      ..hosts = [...hosts]
      ..passives = [...passives]
      ..arbiters = [...arbiters]
      ..tags = {...tags}
      ..setName = setName
      ..setVersion = setVersion
      ..electionId = electionId
      ..primary = primary
      ..logicalSessionTimeoutMinutes = logicalSessionTimeoutMinutes
      ..saslSupportedMechs = saslSupportedMechs
      ..dart_mock_server = dart_mock_server
      ..$clusterTime = $clusterTime;
  }
}
