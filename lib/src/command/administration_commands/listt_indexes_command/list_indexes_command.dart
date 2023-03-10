import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import '../../base/command_operation.dart';

/// listIndexes command.
///
/// Returns information about the indexes on the specified collection.
/// Returned index information includes the keys and options used to create
/// the index, as well as hidden indexes. You can optionally set the
///  batch size for the first batch of results.
///
/// The command accepts the following fields:
/// - db [MongoDatabase]
///   The database on which to query the indexes info
/// - collection [MongoCollection]
///   The collection of which to list the indexes
/// - listIndexesOptions [ListIndexesOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to listIndexesOptions to specify command options
///   (must be manually set)

base class ListIndexesCommand extends CommandOperation {
  ListIndexesCommand(MongoDatabase db, MongoCollection collection,
      {super.session,
      ListIndexesOptions? listIndexesOptions,
      Map<String, Object>? rawOptions})
      : super(db, {},
            <String, dynamic>{...?listIndexesOptions?.options, ...?rawOptions},
            collection: collection);

  @override
  Command $buildCommand() => <String, dynamic>{
        keyListIndexes: collection?.collectionName ?? '',
      };
}
