import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class DistinctResult with BasicResult, TimingResult {
  DistinctResult(Map<String, Object?> document)
      : values = document[keyValues] as List? ?? [] {
    extractBasic(document);
    extractTiming(document);
  }
  List values;
}
