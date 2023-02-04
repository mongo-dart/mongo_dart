import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/base/mongo_database.dart';
import 'drop_database_options.dart';

/// dropDatabase command.
///
/// The dropDatabase command drops the current database,
/// deleting the associated data files.
///
/// The command accepts the following fields:
/// - db [MongoDatabase]
///   The database to be dropped
/// - dropDatabaseOptions [DropDatabaseOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to dropDatabaseOptions to specify command options
///   (must be manually set)
class DropDatabaseCommand extends CommandOperation {
  DropDatabaseCommand(MongoDatabase db,
      {super.session,
      DropDatabaseOptions? dropDatabaseOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, dynamic>{
          keyDropDatabase: 1,
        }, <String, dynamic>{
          ...?dropDatabaseOptions?.getOptions(db),
          ...?rawOptions
        });
}
