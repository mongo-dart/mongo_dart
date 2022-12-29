import 'package:mongo_dart/src/command/base/command_operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/mongo_database.dart';
import 'create_options.dart';

/// create command.
///
/// Explicitly creates a collection or view.
///
/// **Note**
/// The view created by this command does not refer to materialized views.
/// For discussion of on-demand materialized views, see `$merge` instead.
///
/// Starting in MongoDB 4.2
/// MongoDB removes the MMAPv1 storage engine and the MMAPv1 specific option
/// flags for create.
///
/// The command accepts the following fields:
/// - db [MongoDatabase]
///   The database on which create the collection or view
/// - name 	[String]
///   The collection or view name to be created.
/// - createOptions [CreateOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to creteOptions to specify command options
///   (must be manually set)
class CreateCommand extends CommandOperation {
  CreateCommand(MongoDatabase db, String name,
      {CreateOptions? createOptions, Map<String, Object>? rawOptions})
      : super(db, <String, dynamic>{
          keyCreate: name,
        }, <String, dynamic>{
          ...?createOptions?.getOptions(db),
          ...?rawOptions
        }) {
    /*   if (name == null) {
      throw MongoDartError('Name required in call to createCommand');
    } */
  }
}
