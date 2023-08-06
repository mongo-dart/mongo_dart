import 'package:mongo_dart/src/command/aggregation_commands/aggregate/aggregate_operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../../database/base/mongo_database.dart';
import '../../../../database/base/mongo_collection.dart';
import '../../../../unions/hint_union.dart';
import 'change_stream_options.dart';

base class ChangeStreamOperation extends AggregateOperation {
  ChangeStreamOperation(Object pipeline,
      {MongoCollection? collection,
      MongoDatabase? db,
      int? batchSize,
      HintUnion? hint,
      ChangeStreamOptions? changeStreamOptions,
      Map<String, Object>? rawOptions})
      : super(
          pipeline,
          collection: collection,
          db: db,
          cursor: batchSize == null
              ? null
              : <String, dynamic>{keyBatchSize: batchSize},
          hint: hint,
          aggregateOptions: changeStreamOptions,
          rawOptions: rawOptions,
        ) {
    this.pipeline.insert(0, <String, dynamic>{
      if (changeStreamOptions == null)
        aggregateChangeStream: <String, dynamic>{}
      else
        aggregateChangeStream: changeStreamOptions.changeStreamSpecificOptions()
    });
  }

  //@override
  //Future<AggregateResult> executeDocument() async => super.executeDocument();
}
