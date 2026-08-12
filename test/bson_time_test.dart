import 'package:bson/bson.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mongo_dart/src/database/commands/mixin/timing_result.dart';
import 'package:mongo_dart/src/database/commands/replication_commands/hello_command/hello_result.dart';
import 'package:mongo_dart/src/database/utils/bson_time.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:test/test.dart';

Map<String, dynamic> _minimalHelloDocument(Object localTime) => {
      keyOk: 1.0,
      keyIsWritablePrimary: true,
      keyLocalTime: localTime,
      keyLogicalSessionTimeoutMinutes: 30,
      keyMinWireVersion: 0,
      keyMaxWireVersion: 17,
    };

void main() {
  group('dateTimeFromBsonValue', () {
    test('passes a DateTime through unchanged', () {
      final now = DateTime.now();
      expect(dateTimeFromBsonValue(now), now);
    });

    test('converts a Timestamp using its seconds', () {
      final result = dateTimeFromBsonValue(Timestamp(1700000000, 1));
      expect(result,
          DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000, isUtc: true));
    });

    test('converts an Int64 (milliseconds since epoch)', () {
      final result = dateTimeFromBsonValue(Int64(1700000000123));
      expect(result,
          DateTime.fromMillisecondsSinceEpoch(1700000000123, isUtc: true));
    });

    test('converts a plain int (milliseconds since epoch)', () {
      final result = dateTimeFromBsonValue(1700000000123);
      expect(result,
          DateTime.fromMillisecondsSinceEpoch(1700000000123, isUtc: true));
    });

    test('returns null for null or unsupported values', () {
      expect(dateTimeFromBsonValue(null), isNull);
      expect(dateTimeFromBsonValue('not a date'), isNull);
    });
  });

  group('HelloResult.localTime', () {
    test('parses a proper DateTime', () {
      final localTime = DateTime.utc(2024, 1, 1);
      final result = HelloResult(_minimalHelloDocument(localTime));
      expect(result.localTime, localTime);
    });

    // Regression test: Azure Cosmos DB / DocumentDB's MongoDB API can send
    // hello.localTime as an Int64 instead of a BSON UTC datetime, which
    // previously caused `type 'Int64' is not a subtype of type 'DateTime'`.
    test('tolerates an Int64 value instead of throwing', () {
      final result = HelloResult(_minimalHelloDocument(Int64(1700000000123)));
      expect(result.localTime,
          DateTime.fromMillisecondsSinceEpoch(1700000000123, isUtc: true));
    });
  });

  group('TimingResult.extractTiming', () {
    test('tolerates an Int64 operationTime', () {
      final timing = _TestTimingResult();
      timing.extractTiming({keyOperationTime: Int64(1700000000123)});
      expect(timing.operationTime,
          DateTime.fromMillisecondsSinceEpoch(1700000000123, isUtc: true));
    });

    test('tolerates an Int64 clusterTime', () {
      final timing = _TestTimingResult();
      timing.extractTiming({keyClusterTime: Int64(1700000000123)});
      expect(timing.$clusterTime?.clusterTime,
          DateTime.fromMillisecondsSinceEpoch(1700000000123, isUtc: true));
    });
  });
}

class _TestTimingResult with TimingResult {}
