import 'package:bson/bson.dart';
import 'package:mongo_dart/mongo_dart.dart' show DbCollection, MongoDartError;
import 'package:mongo_dart/src/database/operation/base/command_operation.dart';
import 'get_more_options.dart';
import 'get_more_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// getMore command.
///
/// Use in conjunction with commands that return a cursor,
/// e.g. find and aggregate, to return subsequent batches of documents
/// currently pointed to by the cursor.
///
/// The command accepts the following fields:
/// * collection 	[DbCollection]
///   - The collection over which the cursor is operating.
/// * cursorId int
///   -	The cursor id of the original find or aggregate operations.
/// * getMoreOptions [GetMoreOptions] - Optional
///   - a set of optional values for the command
class GetMoreCommand extends CommandOperation {
  GetMoreCommand(DbCollection collection, BsonLong cursorId,
      {GetMoreOptions getMoreOptions, Map<String, Object> rawOptions})
      : super(null, getMoreOptions?.options ?? rawOptions,
            collection: collection,
            command: <String, Object>{
              keyGetMore: cursorId,
              keyCollection: collection?.collectionName,
            }) {
    if (collection == null) {
      throw MongoDartError('Collection required in call to GetMoreCommand');
    }
    if (cursorId == null) {
      throw MongoDartError('CursorId required in call to GetMoreCommand');
    }
    if (!options.containsKey(keyBatchSize)) {
      options[keyBatchSize] = 101;
    }
  }

  Future<GetMoreResult> executeDocument() async {
    var result = await super.execute();
    return GetMoreResult(result);
  }
}
