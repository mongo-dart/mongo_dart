import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection;
import 'package:mongo_dart/src/database/utils/map_keys.dart'
    show
        keyMaxStalenessSecond,
        keyMode,
        keyPreference,
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

///
/// The **ReadPreference** class is a class that represents a MongoDB ReadPreference and is
/// used to construct connections.
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

  static int getMaxStalenessSeconds(Map<String, Object> options) {
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

  static int getMinWireVersion(Map<String, Object> options) {
    if (options == null) {
      return null;
    }
    if (options[keyMaxStalenessSecond] != null) {
      if (options[keyMaxStalenessSecond] is! int ||
          options[keyMaxStalenessSecond] as int < 0) {
        throw ArgumentError('maxStalenessSeconds must be a positive integer');
      }
      // NOTE: The minimum required wire version is 5 for this read preference. If the existing
      //       topology has a lower value then a MongoError will be thrown during server selection.
      return 5;
    }
    return null;
  }

  final ReadPreferenceMode mode;
  final List tags;
  final Map options;
  final int maxStalenessSeconds;
  final int minWireVersion;

  @Deprecated('Support the deprecated `preference` property '
      'introduced in the porcelain layer')
  ReadPreferenceMode get preference => mode;

  ReadPreference([this.mode, this.tags, Map<String, Object> options])
      : options = options ?? <String, Object>{},
        maxStalenessSeconds = getMaxStalenessSeconds(options),
        minWireVersion = getMinWireVersion(options) {
    if (mode == ReadPreferenceMode.primary) {
      if (tags != null && tags.isNotEmpty) {
        throw ArgumentError(
            'Primary read preference cannot be combined with tags');
      }

      if (maxStalenessSeconds != null) {
        throw ArgumentError(
            'Primary read preference cannot be combined with maxStalenessSeconds');
      }
    }
  }

  factory ReadPreference.fromOptions(Map<String, Object> options) {
    if (options == null || options[keyReadPreference] == null) {
      return null;
    }
    dynamic readPreference = options[keyReadPreference];
    if (readPreference is ReadPreferenceMode) {
      return ReadPreference(
          readPreference, options[keyReadPreferenceTags] as List);
    } else if (readPreference is Map) {
      var mode = (readPreference[keyMode] as ReadPreferenceMode) ??
          (readPreference[keyPreference] as ReadPreferenceMode);
      if (mode != null) {
        return ReadPreference(mode, readPreference[keyTags] as List,
            {keyMaxStalenessSecond: readPreference[keyMaxStalenessSecond]});
      }
    } else if (options[keyReadPreference] is ReadPreference) {
      return options[keyReadPreference] as ReadPreference;
    } else {
      throw UnsupportedError('The "$keyReadPreference" value is of an '
          'unmanaged type ${options[keyReadPreference].runtimeType}');
    }
    return null;
  }

  // As in Dart mode is enum, the value is always valid
  static bool isValid(ReadPreferenceMode mode) => true;

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

  Map<String, Object> toJSON() {
    var readPreference = <String, Object>{
      keyMode: '$mode'.replaceFirst('ReadPreferenceMode.', '')
    };
    if (tags != null) {
      readPreference[keyTags] = tags;
    }
    if (maxStalenessSeconds != null) {
      readPreference[keyMaxStalenessSecond] = maxStalenessSeconds;
    }
    return readPreference;
  }
}

/// Resolves a read preference based on well-defined inheritance rules. This method will not only
/// determine the read preference (if there is one), but will also ensure the returned value is a
/// properly constructed instance of `ReadPreference`.
///
/// @param {Collection|Db|MongoClient} parent The parent of the operation on which to determine the read
/// preference, used for determining the inherited read preference.
/// @param {Object} options The options passed into the method, potentially containing a read preference
/// @returns {(ReadPreference|null)} The resolved read preference
ReadPreference resolveReadPreference(parent, Map<String, Object> options,
    {bool inheritReadPreference}) {
  options ??= {};
  inheritReadPreference ??= true;

  ReadPreference inheritedReadPreference;

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

  ReadPreference readPreference;
  if (options[keyReadPreference] != null) {
    readPreference = ReadPreference.fromOptions(options);
  } // Todo session Class not yet implemented
  /*else if ((session?.inTransaction() ?? false) && session.transaction.options[CommandOperation.keyReadPreference]) {
    // The transaction’s read preference MUST override all other user configurable read preferences.
    readPreference = session.transaction.options[CommandOperation.keyReadPreference];
  }*/
  else if (inheritedReadPreference != null) {
    readPreference = inheritedReadPreference;
  } else {
    if (inheritReadPreference) {
      throw ArgumentError('No readPreference was provided or inherited.');
    }
  }

  return readPreference;
}
