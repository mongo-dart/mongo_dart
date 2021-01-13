import 'package:mongo_dart/mongo_dart.dart'
    show AggregationPipelineBuilder, Db, DbCollection, MongoDartError;
import 'package:mongo_dart/src/database/operation/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'aggregate_options.dart';
import '../../../base/command_operation.dart';
import 'aggregate_result.dart';

/// Collection is the collection on which the operation is performed
/// In case of admin/diagnostic pipeline which does not require an underlying
/// collection, the db parameter must be passed instead.
class AggregateOperation extends CommandOperation {
  AggregateOperation(Object pipeline,
      {DbCollection collection,
      Db db,
      this.explain,
      this.cursor,
      this.hint,
      this.hintDocument,
      AggregateOptions aggregateOptions,
      Map<String, Object> rawOptions})
      : super(
            collection?.db ?? db,
            <String, Object>{
              ...?aggregateOptions?.getOptions(collection?.db ?? db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.readOperation) {
    explain ??= false;
    cursor ??= <String, Object>{};
    if (pipeline is List<Map<String, Object>>) {
      this.pipeline = pipeline;
    } else if (pipeline is AggregationPipelineBuilder) {
      this.pipeline = pipeline.build();
    } else {
      throw MongoDartError('Received pipeline is "${pipeline.runtimeType}", '
          'while the method only accept "AggregationPipelineBuilder" or '
          '"List<Map<String, Object>>" objects');
    }
  }

  /// An array of aggregation pipeline stages that process and transform
  /// the document stream as part of the aggregation pipeline.
  List<Map<String, Object>> pipeline;

  /// Specifies to return the information on the processing of the pipeline.
  ///
  /// **Not available in multi-document transactions.**
  bool explain;

  /// Specify a document that contains options that control the creation of
  /// the cursor object.
  ///
  /// Changed in version 3.6: MongoDB 3.6 removes the use of aggregate command
  /// without the cursor option unless the command includes the explain option.
  /// Unless you include the explain option, you must specify the cursor option.
  ///
  /// To indicate a cursor with the default batch size, specify `cursor: {}`.
  /// To indicate a cursor with a non-default batch size, use
  /// `cursor: { batchSize: <num> }`.
  Map<String, Object> cursor;

  /// Optional. Index specification. Specify either the index name
  /// as a string (hint field) or the index key pattern (hintDocument field).
  /// If specified, then the query system will only consider plans
  /// using the hinted index.
  /// **starting in MongoDB 4.2**, with the following exception,
  /// hint is required if the command includes the min and/or max fields;
  /// hint is not required with min and/or max if the filter is an
  /// equality condition on the _id field { _id: <value> }.
  String hint;
  Map<String, Object> hintDocument;

  @override
  Map<String, Object> $buildCommand() {
    // on null collections (only aggregate) the query is performed
    // on the admin database
    if (collection == null) {
      options[keyDbName] = 'admin';
    }
    return <String, Object>{
      keyAggregate: collection?.collectionName ?? 1,
      keyPipeline: pipeline,
      if (explain) keyExplain: explain,
      keyCursor: cursor,
      if (hint != null)
        keyHint: hint
      else if (hintDocument != null)
        keyHint: hintDocument,
    };
  }

  Future<AggregateResult> executeDocument() async {
    var result = await super.execute();
    return AggregateResult(result);
  }
}
