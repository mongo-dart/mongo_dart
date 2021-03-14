import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class DistinctResult with BasicResult, TimingResult {
  DistinctResult(Map<String, Object> document) {
    extractBasic(document);
    extractTiming(document);
    values = document[keyValues] ?? [];
  }
  List values;
}
