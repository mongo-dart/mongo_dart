import 'package:bson/bson.dart';
import 'package:fixnum/fixnum.dart';

/// Converts a raw BSON value into a [DateTime].
/// Supports [DateTime], [Timestamp], [Int64] and [int] values.
/// Returns `null` if [value] is `null` or of an unsupported type.
DateTime? dateTimeFromBsonValue(Object? value) => switch (value) {
      DateTime() => value,
      Timestamp() =>
        DateTime.fromMillisecondsSinceEpoch(value.seconds * 1000, isUtc: true),
      Int64() =>
        DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true),
      int() => DateTime.fromMillisecondsSinceEpoch(value, isUtc: true),
      _ => null,
    };
