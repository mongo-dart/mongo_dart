import 'package:mongo_dart/mongo_dart.dart'
    show Db, DbCollection, MongoDartError;
import 'package:mongo_dart/src/database/utils/map_keys.dart'
    show
        keyHedgeOptions,
        keyMaxStalenessSecond,
        keyMode,
        keyReadPreference,
        keyReadPreferenceTags,
        keyTags;

enum ReadPreferenceMode {
  primary,
  primaryPreferred,
  secondary,
  secondaryPreferred,
  nearest
}

String getReadPreferenceModeString(ReadPreferenceMode mode) =>
    '$mode'.replaceFirst('ReadPreferenceMode.', '');
ReadPreferenceMode getReadPreferenceModeFromString(String mode) =>
    ReadPreferenceMode.values
        .firstWhere((element) => '$element' == 'ReadPreferenceMode.$mode');

///
/// The **ReadPreference** class is a class that represents a MongoDB
/// ReadPreference and is used to construct connections.
///  @class
/// @param {string} mode A string describing the read preference mode (primary|primaryPreferred|secondary|secondaryPreferred|nearest)
/// @param {array} tags The tags object
/// @param {object} [options] Additional read preference options
/// @param {number} [options.maxStalenessSeconds] Max secondary read staleness in seconds, Minimum value is 90 seconds.
/// @see https://docs.mongodb.com/manual/core/read-preference/
/// @return {ReadPreference}
class ReadPreference {
  static const needSlaveOk = [
    ReadPreferenceMode.primaryPreferred,
    ReadPreferenceMode.secondary,
    ReadPreferenceMode.secondaryPreferred,
    ReadPreferenceMode.nearest
  ];

  static ReadPreference primary = ReadPreference(ReadPreferenceMode.primary);
  static ReadPreference primaryPreferred =
      ReadPreference(ReadPreferenceMode.primaryPreferred);
  static ReadPreference secondary =
      ReadPreference(ReadPreferenceMode.secondary);
  static ReadPreference secondaryPreferred =
      ReadPreference(ReadPreferenceMode.secondaryPreferred);
  static ReadPreference nearest = ReadPreference(ReadPreferenceMode.nearest);

  static int? getMaxStalenessSeconds(Map<String, Object>? options) {
    if (options == null) {
      return null;
    }
    if (options[keyMaxStalenessSecond] != null) {
      if (options[keyMaxStalenessSecond] is! int ||
          options[keyMaxStalenessSecond] as int < 0) {
        throw ArgumentError('maxStalenessSeconds must be a positive integer');
      }
      return options[keyMaxStalenessSecond] as int;
    }
    return null;
  }

  final ReadPreferenceMode mode;
  final List? tags;
  //final Map<String, Object> options;
  final int? maxStalenessSeconds;
  final Map<String, Object>? hedgeOptions;

  /* @Deprecated('Support the deprecated `preference` property '
      'introduced in the porcelain layer')
  ReadPreferenceMode get preference => mode; */

  ReadPreference(this.mode,
      {this.tags, this.maxStalenessSeconds, this.hedgeOptions}) {
    if (mode == ReadPreferenceMode.primary) {
      if (tags != null && tags!.isNotEmpty) {
        throw ArgumentError(
            'Primary read preference cannot be combined with tags');
      }
      if (maxStalenessSeconds != null) {
        throw ArgumentError(
            'Primary read preference cannot be combined with maxStalenessSeconds');
      }
    }
    if (maxStalenessSeconds != null && maxStalenessSeconds! < 0) {
      throw ArgumentError('maxStalenessSeconds must be a positive integer');
    }
  }

  /// We can accept three formats for ReadPreference inside Options:
  /// - options[keyReadPreference] id ReadPreference
  ///    an Instance of ReadPreference)
  /// - options[keyReadPrefernce] is Map (in format:
  ///    {keyMode: <String>,
  ///     keyReadPrefernceTags: <List>,
  ///     keyMaxStalenessSeconds: <int>,
  ///     keyHedgedOptions: <map>
  ///    })
  /// - options[keyReadPreference] is ReadPreferenceMode.
  ///   In this this case we expect the other options to be inside the options
  ///   map itself (ex. options[keyReadPreferencTags])
  ///
  factory ReadPreference.fromOptions(Map<String, Object> options) {
    if (options[keyReadPreference] == null) {
      throw MongoDartError('ReadPreference mode is needed');
    }
    dynamic readPreference = options[keyReadPreference];
    if (readPreference is ReadPreferenceMode) {
      return ReadPreference(readPreference,
          tags: options[keyReadPreferenceTags] as List?,
          maxStalenessSeconds: options[keyMaxStalenessSecond] as int?,
          hedgeOptions: options[keyHedgeOptions] as Map<String, Object>?);
    } else if (readPreference is Map) {
      var mode = readPreference[keyMode] as String?;
      if (mode != null) {
        return ReadPreference(getReadPreferenceModeFromString(mode),
            tags: readPreference[keyReadPreferenceTags] as List?,
            maxStalenessSeconds: readPreference[keyMaxStalenessSecond] as int?,
            hedgeOptions:
                readPreference[keyHedgeOptions] as Map<String, Object>?);
      }
    } else if (options[keyReadPreference] is ReadPreference) {
      return options[keyReadPreference] as ReadPreference;
    }
    throw UnsupportedError('The "$keyReadPreference" value is of an '
        'unmanaged type ${options[keyReadPreference].runtimeType}');
  }

  // As in Dart mode is enum, the value is always valid
  /* static bool isValid(ReadPreferenceMode mode) => true; */

  ///
  /// Indicates that this readPreference needs the "slaveOk" bit when sent over the wire
  /// @method
  /// @return {boolean}
  /// @see https://docs.mongodb.com/manual/reference/mongodb-wire-protocol/#op-query
  bool get slaveOk => needSlaveOk.contains(mode);

  @override
  bool operator ==(other) => other is ReadPreference && mode == other.mode;

  @override
  int get hashCode => mode.hashCode;

  Map<String, Object> toMap() => <String, Object>{
        keyMode: getReadPreferenceModeString(mode),
        if (tags != null) keyTags: tags!,
        if (maxStalenessSeconds != null)
          keyMaxStalenessSecond: maxStalenessSeconds!,
        if (hedgeOptions != null) keyHedgeOptions: hedgeOptions!
      };
}

/// Resolves a read preference based on well-defined inheritance rules. This method will not only
/// determine the read preference (if there is one), but will also ensure the returned value is a
/// properly constructed instance of `ReadPreference`.
///
/// @param {Collection|Db|MongoClient} parent The parent of the operation on which to determine the read
/// preference, used for determining the inherited read preference.
/// @param {Object} options The options passed into the method, potentially containing a read preference
/// @returns {(ReadPreference|null)} The resolved read preference
ReadPreference? resolveReadPreference(parent, Map<String, Object> options,
    {bool? inheritReadPreference = true}) {
  //options ??= <String, Object>{};
  inheritReadPreference ??= true;

  ReadPreference? inheritedReadPreference;

  if (inheritReadPreference) {
    if (parent is DbCollection) {
      inheritedReadPreference = parent.readPreference;
    } else if (parent is Db) {
      inheritedReadPreference = parent.readPreference;
    } //Todo MongoClient class not yet Implemented
    /*else if (parent is MongoClient) {
    inheritedReadPreference = parent.readPreference;
  }*/
  }

  if (options[keyReadPreference] != null) {
    return ReadPreference.fromOptions(options);
  } // Todo session Class not yet implemented
  /*else if ((session?.inTransaction() ?? false) && session.transaction.options[CommandOperation.keyReadPreference]) {
    // The transaction’s read preference MUST override all other user configurable read preferences.
    readPreference = session.transaction.options[CommandOperation.keyReadPreference];
  }*/
  else if (inheritedReadPreference != null) {
    return inheritedReadPreference;
  } else {
    if (inheritReadPreference) {
      throw ArgumentError('No readPreference was provided or inherited.');
    }
  }
  return null;
}
