part of mongo_dart;

class MongoDartError extends Error {
  final String message;
  MongoDartError(this.message);
  String toString() => "MongoDart Error: $message";
}
