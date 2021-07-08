import 'package:mongo_dart/mongo_dart.dart' show Db, WriteConcern;
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class InsertOptions {
  /// The WriteConcern for this insert operation
  final WriteConcern? writeConcern;

  /// If true, perform an ordered insert of the documents in the array,
  /// and if an error occurs with one of documents, MongoDB will return without
  /// processing the remaining documents in the array.
  ///
  /// If false, perform an unordered insert, and if an error occurs with one of
  /// documents, continue processing the remaining documents in the array.
  ///
  /// Defaults to true.
  final bool ordered;

  /// Enables insert to bypass document validation during the operation.
  ///  This lets you insert documents that do not meet the validation
  /// requirements.
  ///
  /// **New in version 3.2.**
  final bool bypassDocumentValidation;

  InsertOptions(
      {this.writeConcern,
      bool? ordered = true,
      bool? bypassDocumentValidation = false})
      : ordered = ordered ?? true,
        bypassDocumentValidation = bypassDocumentValidation ?? false;

  // The db parameter is used to transform the writeConcern into a Map
  /// When a writeConcern is given a Db object must be specified
  Map<String, Object> getOptions(Db db) {
    return <String, Object>{
      if (writeConcern != null)
        keyWriteConcern: writeConcern!.asMap(db.masterConnection.serverStatus),
      if (!ordered) keyOrdered: ordered,
      if (bypassDocumentValidation)
        keyBypassDocumentValidation: bypassDocumentValidation,
    };
  }
}
