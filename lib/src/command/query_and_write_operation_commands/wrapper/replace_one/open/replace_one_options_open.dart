import '../base/replace_one_options.dart';

class ReplaceOneOptionsOpen extends ReplaceOneOptions {
  ReplaceOneOptionsOpen(
      {super.writeConcern, super.bypassDocumentValidation, super.comment})
      : super.protected();
}
