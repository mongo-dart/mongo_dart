import 'package:mongo_dart/mongo_dart.dart' show DbCollection, WriteConcern;
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class InsertOneOptions {
  final DbCollection collection;
  final WriteConcern writeConcern;
  final bool ordered;

  //Todo collation
  final Map collation;

  // Todo
  //ClientSession session;

  InsertOneOptions(
    this.collection, {
    this.writeConcern,
    bool ordered,
    this.collation,
    /* this.session*/
  }) : ordered = ordered ?? true;

  Map<String, Object> get options => <String, Object>{
        if (writeConcern != null)
          keyWriteConcern:
              writeConcern.asMap(collection.db.masterConnection.serverStatus),
        keyOrdered: ordered,
        if (collation != null)
          keyCollation: collation,
        //if (session != null) keySession: session
      };
}
