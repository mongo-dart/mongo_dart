import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection;
import 'package:mongo_dart/src/database/operation/commands/aggreagation_commands/aggregate/aggregate_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/aggreagation_commands/aggregate/aggregate_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'change_stream_options.dart';

class ChangeStreamOperation extends AggregateOperation {
  ChangeStreamOperation(Object pipeline,
      {DbCollection collection,
      Db db,
      int batchSize,
      String hint,
      Map<String, Object> hintDocument,
      ChangeStreamOptions changeStreamOptions,
      Map<String, Object> rawOptions})
      : super(
          pipeline,
          collection: collection,
          db: db,
          cursor: batchSize == null
              ? null
              : <String, Object>{keyBatchSize: batchSize},
          hint: hint,
          hintDocument: hintDocument,
          aggregateOptions: changeStreamOptions,
          rawOptions: rawOptions,
        ) {
    this.pipeline.insert(0, <String, Object>{
      if (changeStreamOptions == null)
        aggregateChangeStream: <String, Object>{}
      else
        aggregateChangeStream: changeStreamOptions.changeStreamSpecificOptions()
    });
  }

  @override
  Future<AggregateResult> executeDocument() async {
    return super.executeDocument();
  }
}
