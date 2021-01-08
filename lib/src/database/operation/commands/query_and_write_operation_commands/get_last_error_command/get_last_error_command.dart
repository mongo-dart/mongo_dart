import 'package:mongo_dart/mongo_dart.dart'
    show Db, MongoDartError, WriteConcern;
import 'package:mongo_dart/src/database/operation/base/command_operation.dart';
import 'get_last_error_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

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
/// * db 	[Db]
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
  GetLastErrorCommand(Db db,
      {WriteConcern writeConcern,
      GetLastErrorOptions getLastErrorOptions,
      Map<String, Object> rawOptions})
      : super(db, getLastErrorOptions?.options ?? rawOptions,
            command: <String, Object>{
              keyGetLastError: 1,
              //keyDbName: db.databaseName,
            }) {
    if (db == null) {
      throw MongoDartError('Database required in call to GetLastErrorCommand');
    }
    if (writeConcern != null) {
      options = {
        ...writeConcern.asMap(db.masterConnection.serverStatus)
          ..remove(keyFsync),
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
  Future<Map<String, Object>> execute() async {
    var result = await super.execute();
    if (result != null && result.isNotEmpty) {
      String res = result['err'];
      if (res != null && res.isNotEmpty) {
        throw result;
      }
    }
    return result;
  }
}
