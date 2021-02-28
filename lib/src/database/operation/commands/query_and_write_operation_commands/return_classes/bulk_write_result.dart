import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/write_concern_error.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'abstract_write_result.dart';
import 'bulk_write_error.dart';
import 'upserted_info.dart';

class BulkWriteResult extends AbstractWriteResult {
  List<UpsertedInfo> upserted = [];
  List<BulkWriteError> writeErrors = [];
  List ids;
  List<Map<String, Object>> documents;

  BulkWriteResult.fromMap(
      WriteCommandType writeCommandType, Map<String, Object> result)
      : super.fromMap(writeCommandType, result) {
    if (result[keyWriteErrors] != null &&
        (result[keyWriteErrors] as List).isNotEmpty) {
      writeErrors = [
        for (var errorMap in (result[keyWriteErrors] as List))
          BulkWriteError.fromMap(errorMap)
      ];
    }
  }

  @override
  bool get hasWriteErrors => writeErrors.isNotEmpty;

  @override
  int get writeErrorsNumber => writeErrors.length;

  void mergeFromMap(
      WriteCommandType writeCommandType, Map<String, Object> result) {
    if (this.writeCommandType != writeCommandType) {
      this.writeCommandType = null;
    }
    serverResponses.add(result);
    if (result[keyOk] == 0.0) {
      ok = result[keyOk];
    }
    // When there is an error (such that 'ok' == 0.0), the 'n' element
    // is not returned
    if (result.containsKey(keyN)) {
      switch (writeCommandType) {
        case WriteCommandType.insert:
          nInserted += result[keyN];
          break;
        case WriteCommandType.update:
          nMatched += result[keyN];
          break;
        case WriteCommandType.delete:
          nRemoved += result[keyN];
          break;
      }
    }
    if (result.containsKey(keyNModified)) {
      nModified += result[keyNModified];
    }
    if (result[keyUpserted] != null) {
      nUpserted += (result[keyUpserted] as List).length;
    }
    if (result.containsKey(keyWriteConcernError)) {
      writeConcernError =
          WriteConcernError.fromMap(result[keyWriteConcernError]);
    }
    if (result[keyWriteErrors] != null &&
        (result[keyWriteErrors] as List).isNotEmpty) {
      writeErrors = [
        ...writeErrors,
        for (var errorMap in (result[keyWriteErrors] as List))
          BulkWriteError.fromMap(errorMap)
      ];
    }
  }
}
