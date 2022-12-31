import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../base/operation_base.dart';
import '../open/delete_options_open.dart';
import '../v1/delete_options_v1.dart';

abstract class DeleteOptions {
  @protected
  DeleteOptions.protected({this.writeConcern, bool? ordered, this.comment})
      : ordered = ordered ?? true;

  factory DeleteOptions(
      {ServerApi? serverApi,
      WriteConcern? writeConcern,
      bool? ordered,
      String? comment}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return DeleteOptionsV1(
          writeConcern: writeConcern, ordered: ordered, comment: comment);
    }
    return DeleteOptionsOpen(
        writeConcern: writeConcern, ordered: ordered, comment: comment);
  }

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

  DeleteOptionsOpen get toOpen => this is DeleteOptionsOpen
      ? this as DeleteOptionsOpen
      : DeleteOptionsOpen(
          writeConcern: writeConcern, ordered: ordered, comment: comment);

  DeleteOptionsV1 get toV1 => this is DeleteOptionsV1
      ? this as DeleteOptionsV1
      : DeleteOptionsV1(
          writeConcern: writeConcern, ordered: ordered, comment: comment);

  // The db parameter is used to transform the writeConcern into a Map
  /// When a writeConcern is given a Db object must be specified
  Options getOptions(MongoDatabase db) => <String, dynamic>{
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(db.server.serverStatus),
        if (!ordered) keyOrdered: ordered,
        if (comment != null) keyComment: comment!
      };
}
