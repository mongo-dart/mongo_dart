import 'package:bson/bson.dart';
import 'package:mongo_dart/mongo_dart.dart' show DbCollection, MongoDartError;
import 'package:mongo_dart/src/database/operation/base/command_operation.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

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
/// * collection 	[DbCollection]
///   - The collection over which the cursor is operating.
/// * cursorIds List<int>
///   -	The cursor ids list to be closed.
/// * killCursorsOptions [KillCursorsOptions] - Optional
///   - a set of optional values for the command
class KillCursorsCommand extends CommandOperation {
  KillCursorsCommand(DbCollection collection, List<BsonLong> cursorIds,
      {KillCursorsOptions killCursorsOptions, Map<String, Object> rawOptions})
      : super(null, killCursorsOptions?.options ?? rawOptions,
            collection: collection,
            command: <String, Object>{
              keyKillCursors: collection?.collectionName,
              keyCursors: cursorIds,
            }) {
    if (collection == null) {
      throw MongoDartError('Collection required in call to KillCursorsCommand');
    }
    if (cursorIds == null || cursorIds.isEmpty) {
      throw MongoDartError('CursorIds required in call to KillCursorsCommand');
    }
  }

  //List<BsonLong> cursorIds;

  Future<KillCursorsResult> executeDocument() async {
    var result = await super.execute();
    return KillCursorsResult(result);
  }
}
