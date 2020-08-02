import 'package:mongo_dart/mongo_dart.dart' show DbCollection, ObjectId;
import 'package:mongo_dart/src/database/operation/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'options/insert_one_options.dart';
import 'command_operation.dart';

class InsertOneOperation extends CommandOperation {
  Map<String, Object> document;

  InsertOneOperation(
      DbCollection collection, this.document, InsertOneOptions insertOneOptions)
      : super(collection.db, insertOneOptions.options,
            collection: collection, aspect: Aspect.writeOperation) {
    if (document == null) {
      throw ArgumentError('Document required in insertOne() method');
    }
    ObjectId id = document[keyId];
    if (id == null) {
      document[keyId] = ObjectId();
    }
  }

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      'insert': collection.collectionName,
      'documents': [document],
      'ordered': options[keyOrdered]
    };
  }

  @override
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
      ret[keyOps] = [document];
      ret[keyInsertedCount] = 1;
      ret[keyInsertedId] = document[keyId];
    }
    return ret;
  }
}
