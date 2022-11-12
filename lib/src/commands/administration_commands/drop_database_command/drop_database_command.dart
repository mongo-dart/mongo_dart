import 'package:mongo_dart/src/commands/base/command_operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/db.dart';
import 'drop_database_options.dart';

/// dropDatabase command.
///
/// The dropDatabase command drops the current database,
/// deleting the associated data files.
///
/// The command accepts the following fields:
/// - db [Db]
///   The database to be dropped
/// - dropDatabaseOptions [DropDatabaseOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to dropDatabaseOptions to specify command options
///   (must be manually set)
class DropDatabaseCommand extends CommandOperation {
  DropDatabaseCommand(Db db,
      {DropDatabaseOptions? dropDatabaseOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, Object>{
          ...?dropDatabaseOptions?.getOptions(db),
          ...?rawOptions
        }, command: <String, Object>{
          keyDropDatabase: 1,
        });
}
