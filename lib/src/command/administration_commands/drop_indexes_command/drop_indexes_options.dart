import 'package:mongo_dart/mongo_dart.dart';

import '../../../database/mongo_collection.dart';

class DropIndexesOptions {
  /// The WriteConcern for this insert operation
  WriteConcern? writeConcern;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the following
  /// locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  /// We limit Comment to String only
  ///
  /// New in version 4.4.
  final String? comment;

  DropIndexesOptions({this.writeConcern, this.comment});

  Map<String, Object> getOptions(MongoCollection collection) =>
      <String, Object>{
        if (writeConcern != null)
          keyWriteConcern:
              writeConcern!.asMap(collection.db.server.serverStatus),
        if (comment != null) keyComment: comment!,
      };
}
