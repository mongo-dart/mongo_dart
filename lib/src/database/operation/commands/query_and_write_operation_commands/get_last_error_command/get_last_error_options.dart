import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// GetLastError command options;
///
/// Optional parameters that can be used whith the GetLastError command:
/// `wtimeout` 	integer
/// - Milliseconds. Specify a value in milliseconds to control how long to wait
///   for write propagation to complete. If replication does not complete
///   in the given timeframe, the getLastError command will return with an
///   error status.
/// `comment` 	string 	- @Since 4.4
/// - A user-provided comment to attach to this command. Once set,
///   this comment appears alongside records of this command in the
///   following locations:
///   * mongod log messages, in the attr.command.cursor.comment field.
///   * Database profiler output, in the command.comment field.
///   * currentOp output, in the command.comment field.
///
///   MongoDb allows any kind of BSON type for this option, but we are
///   limiting it to Strings only.
///
class GetLastErrorOptions {
  final int wtimeout;
  final String comment;

  GetLastErrorOptions({this.wtimeout, this.comment});

  Map<String, Object> get options => <String, Object>{
        if (wtimeout != null) keyWtimeout: wtimeout,
        if (comment != null) keyComment: comment,
      };
}
