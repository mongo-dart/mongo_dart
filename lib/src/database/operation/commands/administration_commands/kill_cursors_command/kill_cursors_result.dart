import 'package:mongo_dart/src/database/operation/mixin/basic_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class KillCursorsResult with BasicResult {
  KillCursorsResult(Map<String, Object> document) {
    extractBasic(document);
    List docs = document[keyCursorsKilled] ?? [];
    if (docs.isNotEmpty) {
      cursorsKilled = <int>[];
    }
    for (var cursorKilled in docs) {
      cursorsKilled.add(cursorKilled);
    }
    docs = document[keyCursorsNotFound] ?? [];
    if (docs.isNotEmpty) {
      cursorsNotFound = <int>[];
    }
    for (var cursorNotFound in docs) {
      cursorsNotFound.add(cursorNotFound);
    }
    docs = document[keyCursorsAlive] ?? [];
    if (docs.isNotEmpty) {
      cursorsAlive = <int>[];
    }
    for (var cursorAlive in docs) {
      cursorsAlive.add(cursorAlive);
    }
    docs = document[keyCursorsUnknown] ?? [];
    if (docs.isNotEmpty) {
      cursorsUnknown = <int>[];
    }
    for (var cursorUnknown in docs) {
      cursorsUnknown.add(cursorUnknown);
    }
  }

  List<int> cursorsKilled;
  List<int> cursorsNotFound;
  List<int> cursorsAlive;
  List<int> cursorsUnknown;
}
