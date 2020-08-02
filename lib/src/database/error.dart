part of mongo_dart;

class MongoDartError extends Error {
  final String message;
  MongoDartError(this.message);
  @override
  String toString() => 'MongoDart Error: $message';
}
