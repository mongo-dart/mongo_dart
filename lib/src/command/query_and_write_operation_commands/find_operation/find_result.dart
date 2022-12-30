import 'package:mongo_dart/src/command/base/cursor_result.dart';
import 'package:mongo_dart/src/command/mixin/basic_result.dart';
import 'package:mongo_dart/src/command/mixin/timing_result.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

class FindResult with BasicResult, TimingResult {
  FindResult(Map<String, dynamic> document)
      : cursor = CursorResult(
            document[keyCursor] as Map<String, Object>? ?? <String, Object>{}) {
    extractBasic(document);
    extractTiming(document);
  }
  CursorResult cursor;
}
