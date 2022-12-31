import '../base/update_one_options.dart';

class UpdateOneOptionsV1 extends UpdateOneOptions {
  UpdateOneOptionsV1(
      {super.writeConcern, super.bypassDocumentValidation, super.comment})
      : super.protected();
}
