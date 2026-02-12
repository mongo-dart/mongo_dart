import 'package:mongo_dart/src/database/utils/map_keys.dart';

class LastErrorObject {
  /// Contains true if an update operation modified an existing document.
  bool updatedExisting;

  /// Contains the value of the _id field of the inserted document if an update
  /// operation with upsert: true resulted in a new document.
  /// Can be an ObjectId, String, or any valid BSON type.
  dynamic upserted;

  int? n;

  LastErrorObject.fromMap(Map document)
      : updatedExisting = document[keyUpdatedExisting] as bool? ?? false {
    upserted = document[keyUpserted];
    n = document[keyN] as int?;
  }
}
