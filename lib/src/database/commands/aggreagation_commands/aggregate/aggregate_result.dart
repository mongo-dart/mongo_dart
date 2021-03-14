import 'package:mongo_dart/src/database/commands/base/cursor_result.dart';
import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class AggregateResult with BasicResult, TimingResult {
  AggregateResult(Map<String, Object> document) {
    extractBasic(document);
    cursor = CursorResult(document[keyCursor]);
    extractTiming(document);
  }
  CursorResult cursor;
}
