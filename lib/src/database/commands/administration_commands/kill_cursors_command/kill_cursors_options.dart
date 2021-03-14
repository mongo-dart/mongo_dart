import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// KillCursors command options;
///
/// Optional parameters that can be used whith the killCursors command:
/// `comment` 	string 	- @Since 4.4
/// - A user-provided comment to attach to this command. Once set,
///   this comment appears alongside records of this command in the
///   following locations:
///   * mongod log messages, in the attr.command.cursor.comment field.
///   * Database profiler output, in the command.comment field.
///   * currentOp output, in the command.comment field.
///
///   MongoDb allows any kind of BSON type for this option, but we are
///   limiting it to String only.
///
class KillCursorsOptions {
  final String comment;

  KillCursorsOptions({this.comment});
  Map<String, Object> get options => <String, Object>{
        if (comment != null) keyComment: comment,
      };
}
