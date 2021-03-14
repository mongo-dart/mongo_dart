import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';
import 'package:mongo_dart/src/database/commands/parameters/read_concern.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class DistinctOptions {
  /// Starting in MongoDB 3.6, the readConcern option has the following syntax:
  /// readConcern: { level: <value> }
  /// Possible read concern levels are:
  /// - "local". This is the default read concern level for read operations
  /// against primary and read operations against secondaries when associated
  /// with causally consistent sessions.
  /// - "available". This is the default for reads against secondaries when
  ///    when not associated with causally consistent sessions. The query returns the instance’s most recent data.
  /// - "majority". Available for replica sets that use WiredTiger storage engine.
  /// - "linearizable". Available for read operations on the primary only.
  /// For more formation on the read concern levels, see [Read Concern Levels](https://docs.mongodb.com/manual/reference/read-concern/#read-concern-levels).
  final ReadConcern readConcern;

  /// Specifies the [collation] to use for the operation.
  /// Collation allows users to specify language-specific rules for string
  /// comparison, such as rules for lettercase and accent marks.
  /// [See Collation document](https://docs.mongodb.com/manual/reference/collation/#collation-document-fields)
  ///
  /// If the collation is unspecified but the collection has a default
  /// collation (see db.createCollection()), the operation uses the collation
  /// specified for the collection.
  ///
  /// If no collation is specified for the collection or for the operations,
  /// MongoDB uses the simple binary comparison used in prior versions for
  /// string comparisons.
  ///
  /// You cannot specify multiple collations for an operation. For example,
  /// you cannot specify different collations per field, or if performing a
  /// find with a sort, you cannot use one collation for the find and another
  /// for the sort.
  ///
  /// New in version 3.4.
  final CollationOptions collation;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the
  /// following locations:
  /// * mongod log messages, in the attr.command.cursor.comment field.
  /// * Database profiler output, in the command.comment field.
  /// * currentOp output, in the command.comment field.
  /// A comment can be only of type String unlike MongoDb that allows
  /// any valid BSON type since 4.4.
  final String comment;

  DistinctOptions({this.readConcern, this.collation, this.comment});

  Map<String, Object> get options => <String, Object>{
        if (readConcern != null) keyReadConcern: readConcern.toMap(),
        if (collation != null) keyCollation: collation.options,
        if (comment != null) keyComment: comment,
      };
}
