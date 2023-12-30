import 'package:mongo_dart/src/database/commands/aggregation_commands/aggregate/aggregate_operation.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'change_stream_options.dart';

class ChangeStreamOperation extends AggregateOperation {
  ChangeStreamOperation(super.pipeline,
      {super.collection,
      super.db,
      int? batchSize,
      super.hint,
      super.hintDocument,
      ChangeStreamOptions? changeStreamOptions,
      super.rawOptions})
      : super(
          cursor: batchSize == null
              ? null
              : <String, Object>{keyBatchSize: batchSize},
          aggregateOptions: changeStreamOptions,
        ) {
    pipeline.insert(0, <String, Object>{
      if (changeStreamOptions == null)
        aggregateChangeStream: <String, Object>{}
      else
        aggregateChangeStream: changeStreamOptions.changeStreamSpecificOptions()
    });
  }

  //@override
  //Future<AggregateResult> executeDocument() async => super.executeDocument();
}
