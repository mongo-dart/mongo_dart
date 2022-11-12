import 'package:mongo_dart/src/commands/aggregation_commands/aggregate/aggregate_operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../../database/db.dart';
import '../../../../database/dbcollection.dart';
import 'change_stream_options.dart';

class ChangeStreamOperation extends AggregateOperation {
  ChangeStreamOperation(Object pipeline,
      {DbCollection? collection,
      Db? db,
      int? batchSize,
      String? hint,
      Map<String, Object>? hintDocument,
      ChangeStreamOptions? changeStreamOptions,
      Map<String, Object>? rawOptions})
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

  //@override
  //Future<AggregateResult> executeDocument() async => super.executeDocument();
}
