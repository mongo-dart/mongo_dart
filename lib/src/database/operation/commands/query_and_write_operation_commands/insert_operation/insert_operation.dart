import 'package:mongo_dart/mongo_dart.dart' show DbCollection, ObjectId;
import 'package:mongo_dart/src/database/operation/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'insert_options.dart';

class InsertOperation extends CommandOperation {
  InsertOperation(DbCollection collection, this.documents,
      {InsertOptions insertOptions, Map<String, Object> rawOptions})
      : super(
            collection.db,
            <String, Object>{
              ...?insertOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation) {
    if (documents == null || documents.isEmpty) {
      throw ArgumentError('Documents required in insert operation');
    }

    ids = List(documents.length);
    for (var idx = 0; idx < documents.length; idx++) {
      documents[idx][key_id] ??= ObjectId();
      ids[idx] = documents[idx][key_id];
    }
  }
  List<Map<String, Object>> documents;
  List ids;

  @override
  Map<String, Object> $buildCommand() => <String, Object>{
        keyInsert: collection.collectionName,
        keyDocuments: documents
      };

  /* @override
  Future<Map<String, Object>> execute() async {
    // Get capabilities
    // Todo manage capabilities
    //const capabilities = db.s.topology.capabilities();

    // Did the user pass in a collation, check if our write server supports it
    // Todo review when we will manage Collation
    /*   if (options.collation && capabilities && !capabilities.commandsTakeCollation) {
      // Create a new error
      final error = MongoDartError('server/primary/mongos does not support collation', errorCode: 67);
      //error.code = 67;
      // Return the error
      throw error;
    }*/

    var ret = await super.execute();
    if (ret[keyOk] == 1.0) {
      ret[keyOps] = documents;
      ret[keyInsertedCount] = 1;
      ret[keyInsertedId] = documents.first[key_Id];
    }
    return ret;
  } */

}
