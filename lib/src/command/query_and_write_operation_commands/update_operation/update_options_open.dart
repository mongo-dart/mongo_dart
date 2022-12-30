import 'base/update_options.dart';

class UpdateOptionsOpen extends UpdateOptions {
  UpdateOptionsOpen(
      {super.writeConcern,
      super.bypassDocumentValidation = false,
      super.comment})
      : super.protected();
}
