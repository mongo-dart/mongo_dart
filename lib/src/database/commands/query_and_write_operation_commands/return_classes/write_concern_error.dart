import 'write_error.dart';

class WriteConcernError extends WriteError {
  Map<String, Object>? errInfo;

  WriteConcernError.fromMap(super.writeConcernErrorMap) : super.fromMap();
}
