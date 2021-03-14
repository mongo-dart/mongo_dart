import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// GetParameter command options;
class GetParameterOptions {
  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the following
  /// locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  /// We limit Comment to String only
  ///
  /// New in version 4.4.
  final String comment;

  const GetParameterOptions({this.comment});

  Map<String, Object> get options => <String, Object>{
        if (comment != null) keyComment: comment,
      };
}
