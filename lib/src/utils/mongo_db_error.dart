import 'generic_error.dart' show GenericError, TemplateError;

class MongoDbError extends GenericError {
  MongoDbError(String errorMessage, {super.errorCode, super.stackTrace})
      : super(errorMessage);
}

class MongoDbTemplateError extends TemplateError {
  MongoDbTemplateError(super.originalErrorMessage,
      {required super.templateMessageCode,
      super.errorCode,
      super.stackTrace,
      super.values});
}
