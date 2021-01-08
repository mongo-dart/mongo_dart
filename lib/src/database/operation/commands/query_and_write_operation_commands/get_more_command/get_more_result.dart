import 'package:mongo_dart/src/database/operation/base/cursor_result.dart';
import 'package:mongo_dart/src/database/operation/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/operation/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class GetMoreResult with BasicResult, TimingResult {
  GetMoreResult(Map<String, Object> document) {
    extractBasic(document);
    cursor = CursorResult(document[keyCursor]);
    extractTiming(document);
  }

  CursorResult cursor;
}
