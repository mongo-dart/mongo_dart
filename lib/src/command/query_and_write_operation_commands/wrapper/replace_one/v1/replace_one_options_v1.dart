import '../base/replace_one_options.dart';

class ReplaceOneOptionsV1 extends ReplaceOneOptions {
  ReplaceOneOptionsV1(
      {super.writeConcern, super.bypassDocumentValidation, super.comment})
      : super.protected();
}
