import '../../core/info/server_status.dart';
import '../../utils/map_keys.dart';

/// [WriteConcern] control the acknowledgment of write operations with
/// various paramaters.
class WriteConcern {
  /// Denotes the Write Concern level that takes the following values
  /// ([int] or [String]):
  /// - -1 Disables all acknowledgment of write operations, and suppresses
  /// all errors, including network and socket errors.
  /// - 0: Disables basic acknowledgment of write operations, but returns
  /// information about socket exceptions and networking errors to the
  /// application.
  /// - 1: Provides acknowledgment of write operations on a standalone mongod
  /// or the primary in a replica set.
  /// - A number greater than 1: Guarantees that write operations have
  /// propagated successfully to the specified number of replica set members
  /// including the primary.
  /// - "majority": Confirms that write operations have propagated to the
  /// majority of configured replica set
  /// - A tag set: Fine-grained control over which replica set members must
  /// acknowledge a write operation
  final dynamic w;

  /// Specifies a timeout for this Write Concern in milliseconds,
  /// or infinite if equal to 0.
  final int? wtimeout;

  /// Enables or disable fsync() operation before acknowledgement of
  /// the requested write operation.
  /// If [true], wait for mongod instance to write data to disk before returning.
  final bool fsync;

  /// Enables or disable journaling of the requested write operation before
  /// acknowledgement.
  /// If [true], wait for mongod instance to write data to the on-disk journal
  /// before returning.
  final bool j;

  /// A string value indicating where the write concern originated
  /// (known as write concern provenance). The following table shows the
  /// possible values for this field and their significance:
  ///
  /// **Provenance** -  **Description**
  /// - clientSupplied
  ///   - The write concern was specified in the application.
  /// - customDefault
  ///   - The write concern originated from a custom defined default value.
  ///     See setDefaultRWConcern.
  /// - getLastErrorDefaults
  ///   - The write concern originated from the replica set’s
  ///       settings.getLastErrorDefaults field.
  /// - implicitDefault
  ///   - The write concern originated from the server in absence of all other
  ///       write concern specifications.
  ///
  /// ** NOTE **
  ///
  /// This field is *only* set by the database when the Write concern is
  /// returned in a writeConcernError. It is **NOT** to be sent to the server
  final String? provenance;

  /// Creates a WriteConcern object
  const WriteConcern(
      {this.w,
      this.wtimeout,
      this.fsync = true,
      this.j = true,
      this.provenance});

  WriteConcern.fromMap(Map<String, Object> writeConcernMap)
      : w = writeConcernMap[keyW],
        wtimeout = writeConcernMap[keyWtimeout] as int?,
        fsync = writeConcernMap[keyFsync] as bool? ?? false,
        j = writeConcernMap[keyJ] as bool? ?? false,
        provenance = writeConcernMap[keyProvenance] as String?;

  /// Write operations that use this write concern will return as soon as the
  /// message is written to the socket.
  /// Exceptions are raised for network issues, but not server errors.
  static const unacknowledged =
      WriteConcern(w: 0, wtimeout: 0, fsync: false, j: false);

  /// Write operations that use this write concern will wait for
  /// acknowledgement from the primary server before returning.
  /// Exceptions are raised for network issues, and server errors.
  static const acknowledged =
      WriteConcern(w: 1, wtimeout: 0, fsync: false, j: false);

  /// Exceptions are raised for network issues, and server errors;
  /// waits for at least 2 servers for the write operation.
  static const replicaAcknowledged =
      WriteConcern(w: 2, wtimeout: 0, fsync: false, j: false);

  /// Exceptions are raised for network issues, and server errors; the write
  /// operation waits for the server to
  /// group commit to the journal file on disk.
  static const journaled =
      WriteConcern(w: 1, wtimeout: 0, fsync: false, j: true);

  /// Exceptions are raised for network issues, and server errors; waits on a
  /// majority of servers for the write operation.
  static const majority =
      WriteConcern(w: 'majority', wtimeout: 0, fsync: false, j: false);

  /// Gets the getlasterror command for this write concern.
  Map<String, dynamic> get command {
    var map = <String, dynamic>{};
    map['getlasterror'] = 1;
    if (w != null) {
      map[keyW] = w;
    }
    if (wtimeout != null) {
      map[keyWtimeout] = wtimeout;
    }
    if (fsync) {
      map[keyFsync] = fsync;
    }
    if (j) {
      map[keyJ] = j;
    }
    return map;
  }

  /// To be used starting with journaled engines (Only Wired Tiger, Journal Only)
  /// For inMemoryEngine the J option is ignored
  ///
  /// We can use before 4.2 testing if the journal is active
  /// (in this case fsync doesn't make any sense, taken from mongodb Jira:
  /// "fsync means sync using a journal if present otherwise the datafiles")
  /// In 4.0 journal cannot be disabled on wiredTiger engine
  /// In 4.2 only wiredTiger can be used
  Map<String, Object> asMap(ServerStatus serverStatus) {
    var ret = <String, Object>{};
    if (w != null) {
      ret[keyW] = w;
    }
    if (wtimeout != null) {
      ret[keyWtimeout] = wtimeout!;
    }
    if (serverStatus.isPersistent) {
      if (j) {
        ret[keyJ] = j;
      }
      if (!j) {
        if (serverStatus.isJournaled) {
          ret[keyJ] = fsync;
        } else {
          ret[keyFsync] = fsync;
        }
      }
    }
    return ret;
  }
}
