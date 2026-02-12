import 'package:bson/bson.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/return_classes/last_error_object.dart';
import 'package:test/test.dart';

void main() {
  group('LastErrorObject', () {
    test('fromMap with ObjectId upserted', () {
      var objectId = ObjectId();
      var leo = LastErrorObject.fromMap({
        'updatedExisting': false,
        'upserted': objectId,
        'n': 1,
      });

      expect(leo.updatedExisting, isFalse);
      expect(leo.upserted, objectId);
      expect(leo.upserted, isA<ObjectId>());
      expect(leo.n, 1);
    });

    test('fromMap with String upserted', () {
      var stringId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      var leo = LastErrorObject.fromMap({
        'updatedExisting': false,
        'upserted': stringId,
        'n': 1,
      });

      expect(leo.updatedExisting, isFalse);
      expect(leo.upserted, stringId);
      expect(leo.upserted, isA<String>());
      expect(leo.n, 1);
    });

    test('fromMap with int upserted', () {
      var leo = LastErrorObject.fromMap({
        'updatedExisting': false,
        'upserted': 42,
        'n': 1,
      });

      expect(leo.updatedExisting, isFalse);
      expect(leo.upserted, 42);
      expect(leo.upserted, isA<int>());
      expect(leo.n, 1);
    });

    test('fromMap with no upserted (update existing)', () {
      var leo = LastErrorObject.fromMap({
        'updatedExisting': true,
        'n': 1,
      });

      expect(leo.updatedExisting, isTrue);
      expect(leo.upserted, isNull);
      expect(leo.n, 1);
    });

    test('fromMap with missing updatedExisting defaults to false', () {
      var leo = LastErrorObject.fromMap({
        'n': 0,
      });

      expect(leo.updatedExisting, isFalse);
      expect(leo.upserted, isNull);
      expect(leo.n, 0);
    });
  });
}
