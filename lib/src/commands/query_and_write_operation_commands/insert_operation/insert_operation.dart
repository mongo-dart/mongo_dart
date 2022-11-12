import 'package:bson/bson.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';
import 'package:mongo_dart/src/commands/base/operation_base.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../database/dbcollection.dart';
import 'insert_options.dart';

class InsertOperation extends CommandOperation {
  InsertOperation(DbCollection collection, this.documents,
      {InsertOptions? insertOptions, Map<String, Object>? rawOptions})
      : ids = List.filled(documents.length, null),
        super(
            collection.db,
            <String, Object>{
              ...?insertOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation) {
    if (documents.isEmpty) {
      throw ArgumentError('Documents required in insert operation');
    }

    for (var idx = 0; idx < documents.length; idx++) {
      documents[idx][key_id] ??= ObjectId();
      ids[idx] = documents[idx][key_id];
    }
  }
  List<Map<String, Object?>> documents;
  List ids;

  @override
  Map<String, Object> $buildCommand() => <String, Object>{
        keyInsert: collection!.collectionName,
        keyDocuments: documents
      };
}
