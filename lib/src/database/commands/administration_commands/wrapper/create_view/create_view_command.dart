import 'package:mongo_dart/mongo_dart.dart' show Db;
import 'package:mongo_dart/src/database/commands/administration_commands/create_command/create_command.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/create_command/create_options.dart';

import 'create_view_options.dart';

/// createView command.
///
/// Creates a view as the result of the applying the specified aggregation
/// pipeline to the source collection or view.
/// Views act as read-only collections, and are computed on demand during
/// read operations. You must create views in the same database as the source
/// collection. MongoDB executes read operations on views as part of the
/// underlying aggregation pipeline.
///
/// The view definition pipeline cannot include the `$out` or the `$merge`
/// stage.
/// If the view definition includes nested pipeline (e.g. the view definition
/// includes `$lookup` or `$facet` stage), this restriction applies to the
/// nested pipelines as well.
///
/// The command accepts the following fields:
/// - db [Db]
///   The database on which create the collection
/// - view 	[String]
///   The view name to be created.
/// - source 	[String]
///   The name of the source collection or view from which to create the view.
///   The name is not the full namespace of the collection or view; i.e.
///   does not include the database name and implies the same database as the
///   view to create. You must create views in the same database as the
///   source collection.
/// - pipeline [List]
///
///   An array that consists of the aggregation pipeline stage(s).
///     `db.createView` creates the view by applying the specified pipeline to
///     the source collection or view.
///
///   The view definition pipeline cannot include the `$out` or the `$merge`
///     stage. If the view definition includes nested pipeline
///     (e.g. the view definition includes `$lookup` or `$facet` stage),
///     this restriction applies to the nested pipelines as well.
///
///   The view definition is public; i.e. `db.getCollectionInfos()` and
///     explain operations on the view will include the pipeline that defines
///     the view.
///     As such, avoid referring directly to sensitive fields and values
///     in view definitions.
/// - createViewOptions [createViewOptions] - Optional
///   a set of optional values for the command
/// - rawOption [Map]
///   An alternative way to creteViewOptions to specify command options
///   (must be manually set)
class CreateViewCommand extends CreateCommand {
  CreateViewCommand(Db db, String view, String source, List pipeline,
      {CreateViewOptions createViewOptions, Map<String, Object> rawOptions})
      : super(db, view,
            createOptions:
                _generateCreateOptions(db, source, pipeline, createViewOptions),
            rawOptions: rawOptions);
}

CreateOptions _generateCreateOptions(
    Db db, String source, List pipeline, CreateViewOptions createViewOptions) {
  return CreateOptions(
      viewOn: source,
      pipeline: pipeline,
      collation: createViewOptions?.collation,
      comment: createViewOptions?.comment);
}
