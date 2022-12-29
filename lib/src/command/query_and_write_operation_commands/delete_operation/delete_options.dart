import 'package:mongo_dart/src/utils/map_keys.dart';
import 'package:mongo_dart/src/command/parameters/write_concern.dart';

import '../../../database/mongo_database.dart';
import '../../base/operation_base.dart';

class DeleteOptions {
  /// The WriteConcern for this delete operation.
  /// Omit to use the default write concern
  final WriteConcern? writeConcern;

  /// If true, then when a delete statement fails, return without performing
  /// the remaining delete statements. If false, then when a delete statement
  /// fails, continue with the remaining delete statements, if any.
  ///
  /// Defaults to true.
  final bool ordered;

  /// A user-provided comment to attach to this command. Once set,
  ///  this comment appears alongside records of this command in the
  /// following locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  ///
  /// We limit this field to String values only
  ///
  /// *New in version 4.4.*
  final String? comment;

  DeleteOptions({this.writeConcern, bool? ordered, this.comment})
      : ordered = ordered ?? true;

  // The db parameter is used to transform the writeConcern into a Map
  /// When a writeConcern is given a Db object must be specified
  Options getOptions(MongoDatabase db) => <String, dynamic>{
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(db.server.serverStatus),
        if (!ordered) keyOrdered: ordered,
        if (comment != null) keyComment: comment!
      };
}
