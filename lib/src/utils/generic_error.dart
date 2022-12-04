class GenericError {
  final String originalErrorMessage;
  final String? errorCode;
  StackTrace? stackTrace;

  GenericError(this.originalErrorMessage, {this.errorCode, this.stackTrace});
}

class TemplateError extends GenericError {
  TemplateError(super.originalErrorMessage,
      {super.errorCode,
      super.stackTrace,
      required this.templateMessageCode,
      this.values});

  String templateMessageCode;
  List? values;
}
