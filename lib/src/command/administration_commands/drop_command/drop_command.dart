import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/base/mongo_database.dart';
import 'drop_options.dart';

/// drop command.
///
/// The drop command removes an entire collection from a database.
///
/// The command accepts the following fields:
/// - db [MongoDatabase]
///   The database on which drop the collection or view
/// - collectionName 	[String]
///   The collection or view name to be dropped.
/// - dropOptions [DropOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to dropOptions to specify command options
///   (must be manually set)
class DropCommand extends CommandOperation {
  DropCommand(MongoDatabase db, String collectionName,
      {super.session, DropOptions? dropOptions, Options? rawOptions})
      : super(db, <String, dynamic>{
          keyDrop: collectionName,
        }, <String, dynamic>{
          ...?dropOptions?.getOptions(db),
          ...?rawOptions
        });
}
