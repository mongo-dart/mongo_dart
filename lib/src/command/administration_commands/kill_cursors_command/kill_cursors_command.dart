import 'package:bson/bson.dart';
import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../core/error/mongo_dart_error.dart';
import '../../../core/network/abstract/connection_base.dart';
import '../../../database/base/mongo_database.dart';
import '../../../database/base/mongo_collection.dart';
import '../../../topology/server.dart';
import 'kill_cursors_options.dart';
import 'kill_cursors_result.dart';

/// killCursors command.
///
/// Kills the specified cursor or cursors for a collection.
/// MongoDB drivers use the killCursors command as part of the
/// client-side cursor implementation.
/// **Note**
/// In general, applications should not use the killCursors command
/// directly.
/// The killCursors command must be run against the database of the
/// collection whose cursors you wish to kill.
///
/// The command accepts the following fields:
/// * collection 	[MongoCollection]
///   - The collection over which the cursor is operating.
/// * cursorIds List<int>
///   -	The cursor ids list to be closed.
/// * killCursorsOptions [KillCursorsOptions] - Optional
///   - a set of optional values for the command
///
/// A driver MAY omit a session ID in killCursors commands for two reasons.
/// First, killCursors is only ever sent to a particular server,
/// so operation teams wouldn't need the lsid for cluster-wide killOp.
/// An admin can manually kill the op with its operation id in the case that
/// it is slow. Secondly, some drivers have a background cursor reaper to
/// kill cursors that aren't exhausted and closed. Due to GC semantics,
/// it can't use the same lsid for killCursors as was used for a cursor's
/// find and getMore, so there's no point in using any lsid at all.
class KillCursorsCommand extends CommandOperation {
  KillCursorsCommand(MongoCollection collection, List<BsonLong> cursorIds,
      {MongoDatabase? db,
      KillCursorsOptions? killCursorsOptions,
      Map<String, Object>? rawOptions})
      : super(
          db ?? collection.db,
          <String, dynamic>{
            keyKillCursors: collection.collectionName,
            keyCursors: cursorIds,
          },
          <String, dynamic>{...?killCursorsOptions?.options, ...?rawOptions},
          collection: collection,
        ) {
    // In case of aggregate collection agnostic commands, collection is
    // not needed
    /*  if (this.db == null) {
      throw MongoDartError('Database required in call to KillCursorsCommand');
    } */
    if (/* cursorIds == null || */ cursorIds.isEmpty) {
      throw MongoDartError('CursorIds required in call to KillCursorsCommand');
    }
  }

  //List<BsonLong> cursorIds;

  Future<KillCursorsResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var result = await super.execute();
    return KillCursorsResult(result);
  }
}
