import 'write_error.dart';

class WriteConcernError extends WriteError {
  Map<String, Object>? errInfo;

  WriteConcernError.fromMap(Map<String, dynamic> writeConcernErrorMap)
      : super.fromMap(writeConcernErrorMap);
}
