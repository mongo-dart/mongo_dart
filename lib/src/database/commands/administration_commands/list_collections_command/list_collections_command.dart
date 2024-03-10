import 'package:mongo_dart/mongo_dart.dart';
import '../../base/command_operation.dart';
import 'list_collections_options.dart';

/// listCollections command.
///
/// Retrieve information, i.e. the name and options, about the
/// collections and views in a database. Specifically,
/// the command returns a document that contains information with which
/// to create a cursor to the collection information. mongosh provides the
/// - db.getCollectionInfos()
/// and the
/// - db.getCollectionNames()
/// helper methods.
///
///
/// The command accepts the following fields:
/// - db [Db]
///   The database on which create the collection or view
/// - filter 	[Map]
///   Optional. A query expression to filter the list of collections.
///  You can specify a query expression on any of the fields
///  returned by listCollections
/// - listCollectionsOptions [ListCollectionsOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to listCollectionsOptions to specify command options
///   (must be manually set)

class ListCollectionsCommand extends CommandOperation {
  ListCollectionsCommand(Db db,
      {this.filter,
      ListCollectionsOptions? listCollectionsOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, Object>{
          ...?listCollectionsOptions?.options,
          ...?rawOptions
        }, command: <String, Object>{
          keyListCollections: 1,
        });

  /// Optional. A query expression to filter the list of collections.
  ///
  /// You can specify a query expression on any of the fields returned
  /// by listCollections
  Map<String, dynamic>? filter;

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyListCollections: 1,
      if (filter != null) keyFilter: filter!,
    };
  }
}
