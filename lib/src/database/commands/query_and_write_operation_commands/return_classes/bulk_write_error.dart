import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'write_error.dart';

class BulkWriteError extends WriteError {
  int? index;
  int? operationInputIndex;

  BulkWriteError.fromMap(Map<String, Object> bulkWriteErrorMap)
      : index = bulkWriteErrorMap[keyIndex] as int?,
        operationInputIndex = bulkWriteErrorMap[keyOperationInputIndex] as int?,
        super.fromMap(bulkWriteErrorMap);
}
