import 'package:mongo_dart/mongo_dart.dart';

/// DropDatabase command options;
///
/// Optional parameters that can be used whith the drop command:
class DropDatabaseOptions {
  /// Optional. A document expressing the write concern of the drop command.
  /// Omit to use the default write concern.
  ///
  /// When issued on a sharded cluster, mongos converts the write concern of
  /// the drop command and its helper db.collection.drop() to "majority"
  final WriteConcern? writeConcern;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the following
  /// locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  ///
  /// Mongo db allows any comment type, but we restrict it to String
  ///
  /// New in version 4.4.
  final String? comment;

  DropDatabaseOptions({
    this.comment,
    this.writeConcern,
  });

  Map<String, Object> getOptions(Db db) => <String, Object>{
        if (writeConcern != null)
          keyWriteConcern:
              writeConcern!.asMap(db.masterConnection.serverStatus),
        if (comment != null) keyComment: comment!,
      };
}
