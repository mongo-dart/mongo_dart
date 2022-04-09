import 'package:mongo_dart/mongo_dart.dart';

List<String> _caseFirstValidValues = <String>['upper', 'lower', 'off'];
List<String> _alternateValidValues = <String>['non-ignorable', 'shifted'];
List<String> _maxVariableValidValues = <String>['punct', 'space'];

/// Collation allows users to specify language-specific rules for string
/// comparison, such as rules for lettercase and accent marks.
/// @Since(3.4)
class CollationOptions {
  /// The ICU locale.
  /// See [Supported Languages and Locales](https://docs.mongodb.com/manual/reference/collation-locales-defaults/#collation-languages-locales)
  /// for a list of supported locales.
  final String locale;

  /// The level of comparison to perform.
  /// Corresponds to [ICU Comparison Levels](http://userguide.icu-project.org/collation/concepts#TOC-Comparison-Levels).
  /// Possible values are: 1, 2, 3, 4, 5
  int? strength;

  /// Flag that determines whether to include case comparison at strength
  /// level 1 or 2. If true, include case comparison; i.e.
  /// When used with strength:1, collation compares base characters and case.
  /// When used with strength:2, collation compares base characters,
  /// diacritics (and possible other secondary differences) and case.
  /// If false, do not include case comparison at level 1 or 2.
  /// The default is false.
  /// For more information, see [ICU Collation: Case Level](http://userguide.icu-project.org/collation/concepts#TOC-CaseLevel).
  bool caseLevel;

  /// A field that determines sort order of case differences during tertiary level comparisons.
  /// Possible values are:
  /// * “upper” 	Uppercase sorts before lowercase.
  /// * “lower” 	Lowercase sorts before uppercase.
  /// * “off” 	Default value. Similar to "lower" with slight differences.
  /// [See](http://userguide.icu-project.org/collation/customization)
  /// for details of differences.
  String? caseFirst;

  /// Flag that determines whether to compare numeric strings as numbers or
  /// as strings.
  /// If true, compare as numbers; i.e. "10" is greater than "2".
  /// If false, compare as strings; i.e. "10" is less than "2".
  /// Default is false.
  bool numericOrdering;

  /// Field that determines whether collation should consider whitespace and
  /// punctuation as base characters for purposes of comparison.
  /// Possible values are:
  /// * "non-ignorable" 	Whitespace and punctuation are considered base
  ///   characters.
  /// * "shifted" 	Whitespace and punctuation are not considered base
  ///   characters and are only distinguished at strength levels greater than 3.
  /// See [ICU Collation: Comparison Levels](http://userguide.icu-project.org/collation/concepts#TOC-Comparison-Levels) for more information.
  /// Default is "non-ignorable".
  String? alternate;

  /// Field that determines up to which characters are considered ignorable
  /// when alternate: "shifted". Has no effect if alternate: "non-ignorable"
  /// Possible values are:
  /// * "punct" 	Both whitespaces and punctuation are “ignorable”,
  ///    i.e. not considered base characters.
  /// * "space" 	Whitespace are “ignorable”,
  ///    i.e. not considered base characters.
  String? maxVariable;

  /// Flag that determines whether strings with diacritics sort from back
  /// of the string, such as with some French dictionary ordering.
  /// If true, compare from back to front.
  /// If false, compare from front to back.
  /// The default value is false.
  bool backwards;

  /// Flag that determines whether to check if text require normalization and
  /// to perform normalization. Generally, majority of text does not require
  /// this normalization processing.
  /// If true, check if fully normalized and perform normalization to compare
  /// text.
  /// If false, does not check.
  /// The default value is false.
  /// [See](http://userguide.icu-project.org/collation/concepts#TOC-Normalization)
  /// for details
  bool normalization;

  CollationOptions(this.locale,
      {this.strength,
      this.caseLevel = false,
      this.caseFirst,
      this.numericOrdering = false,
      this.alternate,
      this.maxVariable,
      this.backwards = false,
      this.normalization = false}) {
    if (strength != null && (strength! < 1 || strength! > 5)) {
      throw MongoDartError(
          'The allowed values for the strngt parameter are 1 to 5');
    }
    if (caseFirst != null && !_caseFirstValidValues.contains(caseFirst)) {
      throw MongoDartError(
          'invalid value "$caseFirst" for the caseFirst parameter');
    }
    if (alternate != null && !_alternateValidValues.contains(alternate)) {
      throw MongoDartError(
          'invalid value "$alternate" for the alternate parameter');
    }
    if (maxVariable != null && !_maxVariableValidValues.contains(maxVariable)) {
      throw MongoDartError(
          'invalid value "$maxVariable" for the maxVariable parameter');
    }
  }

  /// A constructor that accepts a Map with the following schema:
  /// {
  ///   locale: <String>,
  ///   caseLevel: <bool>,
  ///   caseFirst: <String>,
  ///   strength: <int>,
  ///   numericOrdering: <bool>,
  ///   alternate: <String>,
  ///   maxVariable: <String>,
  ///   backwards: <bool>
  ///   normalization: <bool>
  /// }
  factory CollationOptions.fromMap(Map<String, Object> collationMap) {
    if (collationMap[keyLocale] is! String) {
      throw MongoDartError('$keyLocale must be of type String');
    }
    if (collationMap[keyCaseLevel] != null &&
        collationMap[keyCaseLevel] is! bool) {
      throw MongoDartError('$keyCaseLevel must be of type bool');
    }
    if (collationMap[keyCaseFirst] != null &&
        collationMap[keyCaseFirst] is! String) {
      throw MongoDartError('$keyCaseFirst must be of type String');
    }
    if (collationMap[keyStrength] != null &&
        collationMap[keyStrength] is! int) {
      throw MongoDartError('$keyStrength must be of type int');
    }
    if (collationMap[keyNumericOrdering] != null &&
        collationMap[keyNumericOrdering] is! bool) {
      throw MongoDartError('$keyNumericOrdering must be of type bool');
    }
    if (collationMap[keyAlternate] != null &&
        collationMap[keyAlternate] is! String) {
      throw MongoDartError('$keyAlternate must be of type String');
    }
    if (collationMap[keyMaxVariable] != null &&
        collationMap[keyMaxVariable] is! String) {
      throw MongoDartError('$keyMaxVariable must be of type String');
    }
    if (collationMap[keyBackwards] != null &&
        collationMap[keyBackwards] is! bool) {
      throw MongoDartError('$keyBackwards must be of type bool');
    }
    if (collationMap[keyNormalization] != null &&
        collationMap[keyNormalization] is! bool) {
      throw MongoDartError('$keyNormalization must be of type bool');
    }

    return CollationOptions(collationMap[keyLocale] as String,
        caseLevel: collationMap[keyCaseLevel] as bool? ?? false,
        caseFirst: collationMap[keyCaseFirst] as String?,
        strength: collationMap[keyStrength] as int?,
        numericOrdering: collationMap[keyNumericOrdering] as bool? ?? false,
        alternate: collationMap[keyAlternate] as String?,
        maxVariable: collationMap[keyMaxVariable] as String?,
        backwards: collationMap[keyBackwards] as bool? ?? false,
        normalization: collationMap[keyNormalization] as bool? ?? false);
  }

  Map<String, Object> get options => <String, Object>{
        keyLocale: locale,
        if (strength != null) keyStrength: strength!,
        if (caseLevel) keyCaseLevel: caseLevel,
        if (caseFirst != null) keyCaseFirst: caseFirst!,
        if (numericOrdering) keyNumericOrdering: numericOrdering,
        if (alternate != null) keyAlternate: alternate!,
        if (maxVariable != null) keyMaxVariable: maxVariable!,
        if (backwards) keyBackwards: backwards,
        if (normalization) keyNormalization: normalization,
      };
}
