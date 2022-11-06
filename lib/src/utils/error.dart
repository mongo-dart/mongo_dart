class MongoError {
  String errorMessage;
  String? errorCode;
  StackTrace? stackTrace;

  MongoError(this.errorMessage, {this.errorCode, this.stackTrace});
}
