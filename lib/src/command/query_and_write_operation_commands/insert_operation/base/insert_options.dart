import 'package:meta/meta.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_options_open.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_options_v1.dart';
import 'package:mongo_dart/src/server_api.dart';
import 'package:mongo_dart/src/server_api_version.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';
import 'package:mongo_dart/src/command/parameters/write_concern.dart';

import '../../../../database/base/mongo_database.dart';
import '../../../base/operation_base.dart';

abstract class InsertOptions {
  @protected
  InsertOptions.protected(
      {this.writeConcern,
      bool? ordered = true,
      bool? bypassDocumentValidation = false})
      : ordered = ordered ?? true,
        bypassDocumentValidation = bypassDocumentValidation ?? false;

  factory InsertOptions(
      {ServerApi? serverApi,
      WriteConcern? writeConcern,
      bool? ordered = true,
      bool? bypassDocumentValidation = false}) {
    if (serverApi != null && serverApi.version == ServerApiVersion.v1) {
      return InsertOptionsV1(
          writeConcern: writeConcern,
          ordered: ordered,
          bypassDocumentValidation: bypassDocumentValidation);
    }
    return InsertOptionsOpen(
        writeConcern: writeConcern,
        ordered: ordered,
        bypassDocumentValidation: bypassDocumentValidation);
  }

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

  InsertOptionsOpen get toOpen => this is InsertOptionsOpen
      ? this as InsertOptionsOpen
      : InsertOptionsOpen(
          writeConcern: writeConcern,
          ordered: ordered,
          bypassDocumentValidation: bypassDocumentValidation);

  InsertOptionsV1 get toV1 => this is InsertOptionsV1
      ? this as InsertOptionsV1
      : InsertOptionsV1(
          writeConcern: writeConcern,
          ordered: ordered,
          bypassDocumentValidation: bypassDocumentValidation);

  // The db parameter is used to transform the writeConcern into a Map
  /// When a writeConcern is given a Db object must be specified
  Options getOptions(MongoDatabase db) {
    return <String, dynamic>{
      if (writeConcern != null)
        keyWriteConcern: writeConcern!.asMap(db.server.serverStatus),
      if (!ordered) keyOrdered: ordered,
      if (bypassDocumentValidation)
        keyBypassDocumentValidation: bypassDocumentValidation,
    };
  }
}
