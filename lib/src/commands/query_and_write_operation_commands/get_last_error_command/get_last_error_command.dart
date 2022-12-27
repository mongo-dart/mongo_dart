import 'package:mongo_dart/src/commands/parameters/write_concern.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';
import '../../../database/mongo_database.dart';
import 'get_last_error_options.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

/// getLastError command.
///
/// Changed in version 2.6: A new protocol for write operations integrates
///   write concerns with the write operations, eliminating the need for a
///   separate getLastError. Most write methods now return the status
///   of the write operation, including error information.
///   In previous versions, clients typically used the getLastError in
///   combination with a write operation to verify that the write succeeded.
///
/// Returns the error status of the preceding write operation on the
///   current connection.
///
/// The command accepts the following fields:
/// * db 	[MongoDatabase]
///   - The database on which the previous write operation ha been executed.
/// * writeConcern WriteConcern
///   - When running with replication, this is the number of servers to
///     replicate to before returning. A w value of 1 indicates the primary
///     only. A w value of 2 includes the primary and at least one secondary,
///     etc. In place of a number, you may also set w to majority to indicate
///     that the command should wait until the latest write propagates to a
///     majority of the voting replica set members.
///     If using w, you should also use wtimeout. Specifying a value for
///     w without also providing a wtimeout may cause getLastError to block
///     indefinitely.
/// * getLastErrorOptions [GetLastErrorOptions] - Optional
///   - a set of optional values for the command
class GetLastErrorCommand extends CommandOperation {
  GetLastErrorCommand(MongoDatabase db,
      {WriteConcern? writeConcern,
      GetLastErrorOptions? getLastErrorOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, Object>{
          keyGetLastError: 1,
          //keyDbName: db.databaseName,
        }, <String, Object>{
          ...?getLastErrorOptions?.options,
          ...?rawOptions
        }) {
    if (writeConcern != null) {
      options = {
        ...writeConcern.asMap(db.server.serverStatus)..remove(keyFsync),
        ...options,
      };
    }

    /// If not specified, set a default timeout in case "w" have been set
    if ((options.containsKey(keyWriteConcern) || options.containsKey(keyW)) &&
        !options.containsKey(keyWtimeout)) {
      options[keyWtimeout] = 5000;
    }
  }
  // this is needed for compatibility with old command version
  @override
  Future<Map<String, Object?>> execute() async {
    var result = await execute();
    if (result.isNotEmpty) {
      var res = result['err'] as String?;
      if (res != null && res.isNotEmpty) {
        throw result;
      }
    }
    return result;
  }
}
