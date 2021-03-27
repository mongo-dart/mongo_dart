import 'write_error.dart';

class WriteConcernError extends WriteError {
  Map<String, Object>? errInfo;

  WriteConcernError.fromMap(Map<String, Object> writeConcernErrorMap)
      : super.fromMap(writeConcernErrorMap);
}
