import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/write_concern_error.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'abstract_write_result.dart';
import 'bulk_write_error.dart';
import 'upserted_info.dart';

class BulkWriteResult extends AbstractWriteResult {
  List<UpsertedInfo> upserted = [];
  List<BulkWriteError> writeErrors = [];
  List? ids;
  List<Map<String, Object?>>? documents;

  BulkWriteResult.fromMap(
      WriteCommandType writeCommandType, Map<String, Object?> result)
      : super.fromMap(writeCommandType, result) {
    if (result[keyWriteErrors] != null &&
        (result[keyWriteErrors] as List).isNotEmpty) {
      var writeErrorsList = <Map<String, Object>>[];
      for (var element in result[keyWriteErrors] as List) {
        writeErrorsList.add(<String, Object>{...element});
      }
      writeErrors = [
        for (var errorMap in writeErrorsList) BulkWriteError.fromMap(errorMap)
      ];
    }
  }

  @override
  bool get hasWriteErrors => writeErrors.isNotEmpty;

  @override
  int get writeErrorsNumber => writeErrors.length;

  void mergeFromMap(
      WriteCommandType writeCommandType, Map<String, Object?> result) {
    if (this.writeCommandType != writeCommandType) {
      this.writeCommandType = null;
    }
    serverResponses.add(result);
    if (result[keyOk] == 0.0) {
      ok = result[keyOk] as double;
    }
    // When there is an error (such that 'ok' == 0.0), the 'n' element
    // is not returned
    if (result.containsKey(keyN)) {
      switch (writeCommandType) {
        case WriteCommandType.insert:
          nInserted += result[keyN] as int;
          break;
        case WriteCommandType.update:
          nMatched += result[keyN] as int;
          break;
        case WriteCommandType.delete:
          nRemoved += result[keyN] as int;
          break;
      }
    }
    if (result.containsKey(keyNModified)) {
      nModified += result[keyNModified] as int;
    }
    if (result[keyUpserted] != null) {
      nUpserted += (result[keyUpserted] as List).length;
    }
    if (result[keyWriteConcernError] != null) {
      var writeConcernMap = <String, Object>{
        ...result[keyWriteConcernError] as Map
      };
      writeConcernError = WriteConcernError.fromMap(writeConcernMap);
    }
    if (result[keyWriteErrors] != null &&
        (result[keyWriteErrors] as List).isNotEmpty) {
      var writeErrorsList = <Map<String, Object>>[];
      for (var element in result[keyWriteErrors] as List) {
        writeErrorsList.add(<String, Object>{...element});
      }
      writeErrors = [
        ...writeErrors,
        for (var errorMap in writeErrorsList) BulkWriteError.fromMap(errorMap)
      ];
    }
  }
}
