import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/sdam/utils.dart';

import 'common.dart';
import 'ismaster.dart';

const writableServerTypes = <ServerType>{
  ServerType.rSPrimary,
  ServerType.standalone,
  ServerType.mongos
};

const dataBearingServerType = <ServerType>{
  ServerType.rSPrimary,
  ServerType.rSSecondary,
  ServerType.mongos,
  ServerType.standalone
};

/// The client's view of a single server, based on the most recent ismaster outcome.
///
/// Internal type, not meant to be directly instantiated
class ServerDescription {
  String address;
  Ismaster ismaster;
  Error error;
  int roundTripTime;
  DateTime lastUpdateTime;
  DateTime lastWriteDate;
  DateTime opTime;
  ServerType type;
  dynamic topologyVersion;
  // Todo check were it is set
  TopologyType topologyType;

  /// Create a ServerDescription
  /// @param {String} address The address of the server
  /// @param {Object} [ismaster] An optional ismaster response for this server
  /// @param {Object} [options] Optional settings
  /// @param {Number} [options.roundTripTime] The round trip time to ping this server (in ms)
  /// @param {Error} [options.error] An Error used for better reporting debugging
  /// @param {any} [options.topologyVersion] The topologyVersion
  ServerDescription(this.address, Ismaster ismaster, options) {
    options = options ?? {};
    this.ismaster = ismaster.duplicate();

    error = options.error;
    roundTripTime = options.roundTripTime ?? -1;
    lastUpdateTime = DateTime.now();
    lastWriteDate = ismaster?.lastWrite != null
        ? ismaster.lastWrite['lastWriteDate']
        : null;
    opTime = ismaster?.lastWrite != null ? ismaster.lastWrite['opTime'] : null;
    type = parseServerType(ismaster);
    topologyVersion = options['topologyVersion'] ?? ismaster.topologyVersion;

    // normalize case for hosts
    if (this.ismaster.me != null) {
      this..ismaster.me = this.ismaster.me.toLowerCase();
    }
    this.ismaster.hosts = [
      for (var host in this.ismaster.hosts) host.toLowerCase()
    ];
    this.ismaster.passives = [
      for (var host in this.ismaster.passives) host.toLowerCase()
    ];
    this.ismaster.arbiters = [
      for (var host in this.ismaster.arbiters) host.toLowerCase()
    ];
  }

  List get allHosts =>
      [...ismaster.hosts, ...ismaster.arbiters, ismaster.passives];

  /// @return {Boolean} Is this server available for reads
  bool get isReadable => type == ServerType.rSSecondary || isWritable;

  /// @return {bool} Is this server data bearing
  bool get isDataBearing => dataBearingServerType.contains(type);

  /// @return {bool} Is this server available for writes
  bool get isWritable => writableServerTypes.contains(type);

  String get host => address.split(':').first;

  int get port => address.contains(':')
      ? int.parse(address.split(':').last)
      : mongoDefaultPort;

  /// Determines if another `ServerDescription` is equal to this one per the rules defined
  /// in the {@link https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#serverdescription|SDAM spec}
  ///
  /// @param {ServerDescription} other
  /// @return {bool}
  @override
  bool operator ==(Object other) {
    if (other is ServerDescription) {
      final topologyVersionsEqual = topologyVersion == other.topologyVersion ||
          compareTopologyVersion(topologyVersion, other.topologyVersion) == 0;

      return (errorStrictEqual(error, other.error) &&
          type == other.type &&
          ismaster.minWireVersion == other.ismaster.minWireVersion &&
          ismaster.me == other.ismaster.me &&
          arrayStrictEqual(ismaster.hosts, other.ismaster.hosts) &&
          tagsStrictEqual(ismaster.tags, other.ismaster.tags) &&
          ismaster.setName == other.ismaster.setName &&
          ismaster.setVersion == other.ismaster.setVersion &&
          (ismaster.electionId
              ? other.ismaster.electionId &&
                  ismaster.electionId.equals(other.ismaster.electionId)
              : ismaster.electionId == other.ismaster.electionId) &&
          ismaster.primary == other.ismaster.primary &&
          ismaster.logicalSessionTimeoutMinutes ==
              other.ismaster.logicalSessionTimeoutMinutes &&
          topologyVersionsEqual);
    }
    return false;
  }
}

/// Parses an `ismaster` message and determines the server type
///
/// @param {Object} ismaster The `ismaster` message to parse
/// @return {ServerType}
ServerType parseServerType(ismaster) {
  if (!ismaster || !ismaster.ok) {
    return ServerType.unknown;
  }

  if (ismaster.isreplicaset) {
    return ServerType.rSGhost;
  }

  if (ismaster.msg != null && ismaster.msg == 'isdbgrid') {
    return ServerType.mongos;
  }

  if (ismaster.setName) {
    if (ismaster.hidden) {
      return ServerType.rSOther;
    } else if (ismaster.ismaster) {
      return ServerType.rSPrimary;
    } else if (ismaster.secondary) {
      return ServerType.rSSecondary;
    } else if (ismaster.arbiterOnly) {
      return ServerType.rSArbiter;
    } else {
      return ServerType.rSOther;
    }
  }

  return ServerType.standalone;
}

/// Compares two topology versions.
///
/// @param {object} lhs
/// @param {object} rhs
/// @returns A negative number if `lhs` is older than `rhs`; positive if `lhs` is newer than `rhs`; 0 if they are equivalent.
int compareTopologyVersion(lhs, rhs) {
  if (lhs == null || rhs == null) {
    return -1;
  }

  if (lhs.processId.equals(rhs.processId)) {
    // TODO: handle counters as Longs
    if (lhs.counter == rhs.counter) {
      return 0;
    } else if (lhs.counter < rhs.counter) {
      return -1;
    }

    return 1;
  }

  return -1;
}
