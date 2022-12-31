import '../base/update_options.dart';

class UpdateOptionsV1 extends UpdateOptions {
  UpdateOptionsV1(
      {super.writeConcern,
      super.bypassDocumentValidation = false,
      super.comment})
      : super.protected();
}
