import 'package:mongo_dart/src/command/mixin/basic_result.dart';
import 'package:mongo_dart/src/command/mixin/timing_result.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

class DistinctResult with BasicResult, TimingResult {
  DistinctResult(Map<String, dynamic> document)
      : values = document[keyValues] as List? ?? [] {
    extractBasic(document);
    extractTiming(document);
  }
  List values;
}
