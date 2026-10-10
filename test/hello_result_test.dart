import 'package:mongo_dart/src/database/commands/replication_commands/hello_command/hello_result.dart';
import 'package:test/test.dart';

void main() {
  // What Amazon DocumentDB answers to hello: no logicalSessionTimeoutMinutes.
  final documentDbHello = <String, dynamic>{
    'isWritablePrimary': true,
    'maxBsonObjectSize': 16777216,
    'maxMessageSizeBytes': 48000000,
    'maxWriteBatchSize': 100000,
    'localTime': DateTime.utc(2026, 10, 7),
    'minWireVersion': 0,
    'maxWireVersion': 13,
    'ok': 1.0,
  };

  test('reads a hello reply without logicalSessionTimeoutMinutes', () {
    final result = HelloResult(documentDbHello);

    expect(result.logicalSessionTimeoutMinutes, isNull);
    expect(result.isWritablePrimary, isTrue);
    expect(result.maxWireVersion, 13);
  });

  test('reads logicalSessionTimeoutMinutes when the server sends it', () {
    final result =
        HelloResult({...documentDbHello, 'logicalSessionTimeoutMinutes': 30});

    expect(result.logicalSessionTimeoutMinutes, 30);
  });
}
