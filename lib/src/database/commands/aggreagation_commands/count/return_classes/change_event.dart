import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:mongo_dart/src/database/utils/mongo_db_namespace.dart';

class ChangeEvent {
  ChangeEvent.fromMap(Map<String, Object> streamData) {
    serverResponse = _extractEventData(streamData);
  }

  Map<String, Object> serverResponse;

  /// Metadata related to the operation. Acts as the resumeToken for the
  /// resumeAfter parameter when resuming a change stream.
  /// `{
  ///   "_data" : <BinData|hex string>
  /// }`
  ///
  /// The _data type depends on the MongoDB versions and, in some cases,
  /// the feature compatibility version (fcv) at the time of the change stream’s
  /// opening/resumption. For details, see [Resume Tokens](https://docs.mongodb.com/manual/changeStreams/#change-stream-resume-token).
  Map<String, Object> id;

  /// The type of operation that occurred. Can be any of the following values:
  /// - insert
  /// - delete
  /// - replace
  /// - update
  /// - drop
  /// - rename
  /// - dropDatabase
  /// - invalidate
  String operationType;

  /// The document created or modified by the insert, replace, delete,
  /// update operations (i.e. CRUD operations).
  ///
  /// For insert and replace operations, this represents the new document
  /// created by the operation.
  ///
  /// For delete operations, this field is omitted as the document no
  /// longer exists.
  ///
  /// For update operations, this field only appears if you configured the
  /// change stream with fullDocument set to updateLookup.
  /// This field then represents the most current majority-committed version of
  /// the document modified by the update operation.
  /// This document may differ from the changes described in updateDescription
  /// if other majority-committed operations modified the document between
  /// the original update operation and the full document lookup.
  Map<String, Object> fullDocument;

  /// The namespace (database and or collection) affected by the event.
  MongoDBNamespace ns;

  bool get isInsert => operationType == 'insert';
  bool get isDelete => operationType == 'delete';
  bool get isReplace => operationType == 'replace';
  bool get isUpdate => operationType == 'update';
  // not yet managed...
  bool get isDrop => operationType == 'drop';
  bool get isRename => operationType == 'rename';
  bool get isDropDatabase => operationType == 'dropDatabase';
  bool get isInvalidate => operationType == 'invalidate';

  Map<String, Object> _extractEventData(Map<String, Object> streamData) {
    id = streamData[key_id];
    operationType = streamData[keyOperationType];
    fullDocument = streamData[keyFullDocument];
    ns = MongoDBNamespace.fromMap(streamData[keyNs]);
    return Map.from(streamData);
  }
}
