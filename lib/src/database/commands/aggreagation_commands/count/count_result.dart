import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class CountResult with BasicResult, TimingResult {
  CountResult(Map<String, Object?> document)
      : count = document[keyN] as int? ?? 0 {
    extractBasic(document);
    extractTiming(document);
  }
  int count;
}
