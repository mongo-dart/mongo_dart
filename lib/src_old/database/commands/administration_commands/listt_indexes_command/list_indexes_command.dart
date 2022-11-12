import 'package:mongo_dart/mongo_dart_old.dart';
import '../../../../../src/commands/base/command_operation.dart';
import 'list_indexes_options.dart';

/// listIndexes command.
///
/// Returns information about the indexes on the specified collection.
/// Returned index information includes the keys and options used to create
/// the index, as well as hidden indexes. You can optionally set the
///  batch size for the first batch of results.
///
/// The command accepts the following fields:
/// - db [Db]
///   The database on which to query the indexes info
/// - collection [DbCollection]
///   The collection of which to list the indexes
/// - listIndexesOptions [ListIndexesOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to listIndexesOptions to specify command options
///   (must be manually set)

class ListIndexesCommand extends CommandOperation {
  ListIndexesCommand(Db db, DbCollection collection,
      {ListIndexesOptions? listIndexesOptions, Map<String, Object>? rawOptions})
      : super(db,
            <String, Object>{...?listIndexesOptions?.options, ...?rawOptions},
            collection: collection);

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyListIndexes: collection?.collectionName ?? '',
    };
  }
}
