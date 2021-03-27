import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/last_error_object.dart';
import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class FindAndModifyResult with BasicResult, TimingResult {
  FindAndModifyResult(Map<String, Object?> document)
      : serverResponse = document {
    extractBasic(document);
    extractTiming(document);
    value = document[keyValue] as Map<String, dynamic>?;
    lastErrorObject =
        LastErrorObject.fromMap(document[keyLastErrorObject] as Map? ?? {});
  }

  /// This is the original response from the server;
  Map<String, Object?> serverResponse;

  /// Contains the command’s returned value.
  /// For remove operations, value contains the removed document if
  /// the query matches a document. If the query does not match a document
  /// to remove, value contains null.
  ///
  /// For update operations, the value embedded document contains the following:
  /// - If the new parameter is not set or is false:
  ///   * the pre-modification document if the query matches a document;
  ///   * otherwise, null.
  /// - If new is true:
  ///   * the modified document if the query returns a match;
  ///   * the inserted document if upsert: true and no document matches the query;
  ///   * otherwise, null.
  Map<String, Object?>? value;

  LastErrorObject? lastErrorObject;
}
