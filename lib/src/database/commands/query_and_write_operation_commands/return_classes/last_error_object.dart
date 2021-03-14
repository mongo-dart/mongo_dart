import 'package:bson/bson.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class LastErrorObject {
  /// Contains true if an update operation modified an existing document.
  bool updatedExisting;

  /// Contains the ObjectId of the inserted document if an update
  /// operation with upsert: true resulted in a new document.
  ObjectId upserted;

  int n;

  LastErrorObject.fromMap(Map document) {
    if (document != null) {
      updatedExisting = document[keyUpdatedExisting];
      upserted = document[keyUpserted];
      n = document[keyN];
    }
    updatedExisting ??= false;
  }
}
