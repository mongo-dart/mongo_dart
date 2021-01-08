part of mongo_dart;

class MongoDartError extends Error {
  final String message;
  final int mongoCode;
  final String errorCode;
  final String errorCodeName;

  MongoDartError(this.message,
      {this.mongoCode, String errorCode, this.errorCodeName})
      : errorCode = errorCode ?? (mongoCode != null ? '$mongoCode' : null);

  @override
  String toString() => 'MongoDart Error: $message';
}
