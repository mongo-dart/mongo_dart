import 'package:mongo_dart/src_old/database/commands/base/cursor_result.dart';
import 'package:mongo_dart/src_old/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src_old/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src_old/database/utils/map_keys.dart';

class FindResult with BasicResult, TimingResult {
  FindResult(Map<String, Object?> document)
      : cursor = CursorResult(
            document[keyCursor] as Map<String, Object>? ?? <String, Object>{}) {
    extractBasic(document);
    extractTiming(document);
  }
  CursorResult cursor;
}
