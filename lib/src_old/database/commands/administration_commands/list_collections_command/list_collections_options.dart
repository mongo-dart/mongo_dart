import 'package:mongo_dart/src_old/database/utils/map_keys.dart';

/// ListCollections command options;
class ListCollectionsOptions {
  /// Optional. A flag to indicate whether the command should return just the
  /// collection/view names and type or return both the name
  /// and other information.
  ///
  /// Returning just the name and type (view or collection) does not
  /// take collection-level locks whereas returning full collection
  /// information locks each collection in the database.
  ///
  /// The default value is false.
  final bool? nameOnly;

  /// A flag, when set to true and used with nameOnly: true,
  /// that allows a user without the required privilege
  /// (i.e. listCollections action on the database)
  /// to run the command when access control is enforced.
  ///
  /// When both authorizedCollections and nameOnly options are set to true,
  /// the command returns only those collections for which the user has
  /// privileges. For example, if a user has find action on specific
  /// collections, the command returns only those collections; or,
  /// if a user has find or any other action, on the database resource,
  /// the command lists all collections in the database.
  ///
  /// The default value is false. That is, the user must have listCollections
  /// action on the database to run the command.
  ///
  /// For a user who has listCollections action on the database,
  /// this option has no effect since the user has privileges to list
  /// the collections in the database.
  ///
  /// When used without nameOnly: true, this option has no effect.
  /// That is, the user must have the required privileges to run the command
  /// when access control is enforced.
  /// Otherwise, the user is unauthorized to run the command.
  ///
  /// New in version 4.0.
  final bool? authorizedCollections;

  /// A user-provided comment to attach to this command. Once set,
  /// this comment appears alongside records of this command in the following
  /// locations:
  /// - mongod log messages, in the attr.command.cursor.comment field.
  /// - Database profiler output, in the command.comment field.
  /// - currentOp output, in the command.comment field.
  /// We limit Comment to String only
  ///
  /// New in version 4.4.
  final String? comment;

  const ListCollectionsOptions(
      {this.nameOnly, this.authorizedCollections, this.comment});

  Map<String, Object> get options => <String, Object>{
        if (nameOnly != null && nameOnly!) keyNameOnly: nameOnly!,
        if (authorizedCollections != null && authorizedCollections!)
          keyAuthorizedCollections: authorizedCollections!,
        if (comment != null) keyComment: comment!,
      };
}
