import 'package:meta/meta.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show
        MongoCollection,
        MongoDartError,
        ServerApiVersion,
        UpdateOptions,
        UpdateStatement,
        keyOrdered,
        keyUpdate,
        keyUpdates;

import '../../../base/command_operation.dart';
import '../open/update_operation_open.dart';
import '../v1/update_operation_v1.dart';

abstract class UpdateOperation extends CommandOperation {
  @protected
  UpdateOperation.protected(MongoCollection collection, this.updates,
      {bool? ordered,
      UpdateOptions? updateOptions,
      Map<String, Object>? rawOptions})
      : ordered = ordered ?? true,
        super(
            collection.db,
            {},
            <String, dynamic>{
              ...?updateOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation);

  factory UpdateOperation(
      MongoCollection collection, List<UpdateStatement> updates,
      {bool? ordered,
      UpdateOptions? updateOptions,
      Map<String, Object>? rawOptions}) {
    if (collection.serverApi != null) {
      switch (collection.serverApi!.version) {
        case ServerApiVersion.v1:
          return UpdateOperationV1(collection, updates,
              ordered: ordered,
              updateOptions: updateOptions?.toV1,
              rawOptions: rawOptions);
        default:
          throw MongoDartError(
              'Stable Api ${collection.serverApi!.version} not managed');
      }
    }
    return UpdateOperationOpen(collection, updates,
        ordered: ordered,
        updateOptions: updateOptions?.toOpen,
        rawOptions: rawOptions);
  }

  /// An array of one or more update statements to perform on the
  /// named collection.
  List<UpdateStatement> updates;

  /// If true, then when an update statement fails, return without performing
  /// the remaining update statements. If false, then when an update fails,
  /// continue with the remaining update statements, if any.
  /// Defaults to true.
  bool ordered;

  @override
  Command $buildCommand() => <String, dynamic>{
        keyUpdate: collection!.collectionName,
        keyUpdates: [for (var request in updates) request.toMap()],
        if (ordered) keyOrdered: ordered,
      };
}
