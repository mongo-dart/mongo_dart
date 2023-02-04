import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import '../../../database/base/mongo_database.dart';
import '../../base/command_operation.dart';

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
/// - db [MongoDatabase]
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
  ListCollectionsCommand(MongoDatabase db,
      {this.filter,
      super.session,
      ListCollectionsOptions? listCollectionsOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, dynamic>{
          keyListCollections: 1,
        }, <String, dynamic>{
          ...?listCollectionsOptions?.options,
          ...?rawOptions
        });

  /// Optional. A query expression to filter the list of collections.
  ///
  /// You can specify a query expression on any of the fields returned
  /// by listCollections
  Map<String, dynamic>? filter;

  @override
  Command $buildCommand() => <String, dynamic>{
        keyListCollections: 1,
        if (filter != null) keyFilter: filter!,
      };
}
