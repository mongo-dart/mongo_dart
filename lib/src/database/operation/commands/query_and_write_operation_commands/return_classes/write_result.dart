import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'abstract_write_result.dart';
import 'write_error.dart';

/// A wrapper that contains the result status of the mongo shell write methods:
/// - insert
/// - update
/// - remove
/// - save
class WriteResult extends AbstractWriteResult {
  dynamic id;
  Map<String, Object> document;
  WriteError writeError;

  WriteResult.fromMap(
      WriteCommandType writeCommandType, Map<String, Object> result)
      : super.fromMap(writeCommandType, result) {
    if (result[keyWriteErrors] != null &&
        (result[keyWriteErrors] as List).isNotEmpty) {
      writeError = WriteError.fromMap((result[keyWriteErrors] as List).first);
    }
  }

  @override
  bool get hasWriteErrors => writeError != null;
 
  @override
  int get writeErrorsNumber => hasWriteErrors ? 1 : 0;
}
