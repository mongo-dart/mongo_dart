import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/operation/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Create command options;
///
/// Optional parameters that can be used whith the create command:
class CreateOptions {
  /// Used to retrieve the serverStatus
  //Db db;

  /// Optional. Specify false to disable the automatic creation of an index on
  /// the _id field.
  ///
  /// **Important**
  /// Starting in MongoDB 4.0, you cannot set the option autoIndexId to false
  /// when creating collections in databases other than the local database.
  ///
  /// Deprecated since version 3.2.
  final bool autoIndexId;

  /// To create a capped collection, specify true.
  /// If you specify true, you must also set a maximum size in the size field.
  final bool capped;

  /// Specify a maximum size in bytes for a capped collection.
  /// Once a capped collection reaches its maximum size,
  /// MongoDB removes the older documents to make space for the new documents.
  /// The size field is required for capped collections and ignored for other
  /// collections. (ex. for 60KB, 60 * 1024)
  final int size;

  /// The maximum number of documents allowed in the capped collection.
  /// The size limit takes precedence over this limit. If a capped collection
  /// reaches the size limit before it reaches the maximum number of documents,
  /// MongoDB removes old documents.
  /// If you prefer to use the max limit, ensure that the size limit,
  /// which is required for a capped collection, is sufficient to contain
  /// the maximum number of documents.
  final int max;

  /// Available for the WiredTiger storage engine only.
  /// Allows users to specify configuration to the storage engine on a
  /// per-collection basis when creating a collection.
  /// The value of the storageEngine option should take the following form:
  ///
  /// `{ <storage-engine-name>: <options> }`
  ///
  /// Storage engine configuration specified when creating collections
  /// are validated and logged to the oplog during replication to support
  /// replica sets with members that use different storage engines.
  final Map<String, dynamic> storageEngine;

  /// Allows users to specify validation rules or expressions for the
  /// collection. For more information, see Schema Validation.
  ///
  /// **New in version 3.2.**
  ///
  /// The validator option takes a document that specifies the validation
  /// rules or expressions. You can specify the expressions using the same
  /// operators as the query operators with the exception of $geoNear,
  /// $near, $nearSphere, $text, and $where.
  ///
  /// **Note**
  /// - Validation occurs during updates and inserts. Existing documents do not
  ///   undergo validation checks until modification.
  /// - You cannot specify a validator for collections in the admin, local,
  ///   and config databases.
  /// - You cannot specify a validator for system.* collections.
  final Map validator;

  /// Determines how strictly MongoDB applies the validation rules to existing
  /// documents during an update.
  ///
  /// **New in version 3.2.**
  ///
  /// |validationLevel|Description|
  /// |---|---|
  /// |"off"|No validation for inserts or updates.|
  /// |"strict"|**Default.** Apply validation rules to all inserts and all updates.|
  /// |"moderate"|Apply validation rules to inserts and to updates on existing valid documents. Do not apply rules to updates on existing invalid documents.|
  final String validationLevel;

  /// Determines whether to error on invalid documents or just warn about the
  /// violations but allow invalid documents to be inserted.
  ///
  /// **New in version 3.2.**
  ///
  /// **Important**
  /// Validation of documents only applies to those documents as determined by
  /// the validationLevel.
  ///
  /// |validationAction |	Description |
  /// | --- | --- |
  /// |"error"|**Default.**  Documents must pass validation before the write occurs. Otherwise, the write operation fails. |
  /// |"warn"|Documents do not have to pass validation. If the document fails validation, the write operation logs the validation failure. |
  final String validationAction;

  /// Allows users to specify a default configuration for indexes when creating
  /// a collection.
  /// The indexOptionDefaults option accepts a storageEngine document, which should take the following form:
  ///
  /// `{ <storage-engine-name>: <options> }`
  ///
  /// Storage engine configuration specified when creating indexes are
  /// validated and logged to the oplog during replication to support
  /// replica sets with members that use different storage engines.
  ///
  /// New in version 3.2.
  final Map<String, dynamic> indexOptionDefaults;

  /// The name of the source collection or view from which to create the view.
  /// The name is not the full namespace of the collection or view;
  /// i.e. does not include the database name and implies the same database as
  /// the view to create.
  /// You must create views in the same database as the source collection.
  ///
  /// See also [db.createView()](https://docs.mongodb.com/manual/reference/method/db.createView/#db.createView).
  ///
  /// New in version 3.4.
  final String viewOn;

  /// An array that consists of the [aggregation pipeline stage(s)](https://docs.mongodb.com/manual/core/aggregation-pipeline/#id1).
  /// create creates the view by applying the specified pipeline to the viewOn
  /// collection or view.
  ///
  /// The view definition pipeline cannot include the `$out` or the `$merge`
  /// stage.
  /// If the view definition includes nested pipeline (e.g. the view definition
  /// includes `$lookup` or `$facet` stage), this restriction applies to the
  /// nested pipelines as well.
  ///
  /// The view definition is public; i.e. `db.getCollectionInfos()` and explain
  /// operations on the view will include the pipeline that defines the view.
  /// As such, avoid referring directly to sensitive fields and values in
  /// view definitions.
  ///
  /// See also [db.createView()](https://docs.mongodb.com/manual/reference/method/db.createView/#db.createView).
  ///
  /// New in version 3.4.
  final List pipeline;

  /// Specifies the default collation for the collection or the view.
  ///
  /// Specifies the default collation for the collection or the view.
  /// Collation allows users to specify language-specific rules for string
  /// comparison, such as rules for lettercase and accent marks.
  ///
  /// If you specify a collation at the collection level:
  /// - Indexes on that collection will be created with that collation unless
  /// the index creation operation explicitly specify a different collation.
  /// - Operations on that collection use the collection’s default collation
  /// unless they explicitly specify a different collation.
  /// - You cannot specify multiple collations for an operation. For example,
  /// you cannot specify different collations per field, or if performing
  /// a find with a sort, you cannot use one collation for the find and another
  /// for the sort.
  ///
  /// If no collation is specified for the collection or for the operations,
  /// MongoDB uses the simple binary comparison used in prior versions for
  /// string comparisons.
  ///
  /// After you create the collection or the view, you cannot update its
  /// default collation.
  ///
  /// For an example that specifies the default collation during the creation
  /// of a collection, see [Specify Collation](https://docs.mongodb.com/manual/reference/command/create/#create-collation-example).
  ///
  /// New in version 3.4.
  final CollationOptions collation;

  /// A document that expresses the write concern for the operation.
  /// Omit to use the default write concern.
  ///
  /// When issued on a sharded cluster, mongos converts the write concern of
  /// the create command and its helper db.createCollection() to "majority".
  final WriteConcern writeConcern;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the following
  /// locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  ///
  /// Mongo db allows any comment type, but we restrict it to String
  ///
  /// New in version 4.4.
  final String comment;

  CreateOptions(
      /*  this.db,  */ {
    bool capped,
    this.size,
    this.comment,
    this.pipeline,
    @Deprecated('Since 3.2') this.autoIndexId,
    this.max,
    this.storageEngine,
    this.validator,
    this.validationLevel,
    this.validationAction,
    this.indexOptionDefaults,
    this.viewOn,
    this.collation,
    this.writeConcern,
  }) : capped = capped ?? false {
    if (this.capped && size == null) {
      throw ArgumentError('A capped collection requires a size');
    }
    if (size != null && size < 1) {
      throw ArgumentError('Size must be a positive integer');
    }
  }

  Map<String, Object> getOptions(Db db) {
    if (writeConcern != null && db == null) {
      throw MongoDartError('Db must be specified when a writeConcern is set');
    }
    if (db != null && db.masterConnection == null) {
      throw MongoDartError('An active connection is required');
    }
    return <String, Object>{
      if (capped != null && capped) keyCapped: capped,
      if (autoIndexId != null && !autoIndexId) keyAutoIndexId: autoIndexId,
      if (size != null) keySize: size,
      if (max != null) keyMax: max,
      if (storageEngine != null) keyStorageEngine: storageEngine,
      if (validator != null) keyValidator: validator,
      if (validationLevel != null) keyValidationLevel: validationLevel,
      if (validationAction != null) keyValidationAction: validationAction,
      if (indexOptionDefaults != null)
        keyIndexOptionDefaults: indexOptionDefaults,
      if (viewOn != null) keyViewOn: viewOn,
      if (pipeline != null) keyPipeline: pipeline,
      if (collation != null) keyCollation: collation.options,
      if (writeConcern != null)
        keyWriteConcern: writeConcern.asMap(db.masterConnection.serverStatus),
      if (comment != null) keyComment: comment,
    };
  }
}
