import '../base/find_options.dart';

class FindOptionsOpen extends FindOptions {
  FindOptionsOpen(
      {super.batchSize,
      super.singleBatch = false,
      super.comment,
      super.maxTimeMS,
      super.readConcern,
      super.max,
      super.min,
      super.returnKey = false,
      super.showRecordId = false,
      super.tailable = false,
      super.oplogReplay = false,
      super.noCursorTimeout = false,
      super.awaitData = false,
      super.allowPartialResult = false,
      super.collation,
      super.allowDiskUse = false})
      : super.protected();
}
