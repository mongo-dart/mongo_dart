import 'package:mongo_dart/mongo_dart.dart' show Db, MongoDartError;
import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

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
/// - db [Db]
///   The database on which create the collection or view
/// - name 	[String]
///   The collection or view name to be created.
/// - createOptions [CreateOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to creteOptions to specify command options
///   (must be manually set)
class CreateCommand extends CommandOperation {
  CreateCommand(Db db, String name,
      {CreateOptions createOptions, Map<String, Object> rawOptions})
      : super(db, <String, Object>{
          ...?createOptions?.getOptions(db),
          ...?rawOptions
        }, command: <String, Object>{
          keyCreate: name,
        }) {
    if (name == null) {
      throw MongoDartError('Name required in call to createCommand');
    }
  }
}
