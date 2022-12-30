import 'base/update_many_options.dart';

class UpdateManyOptionsV1 extends UpdateManyOptions {
  UpdateManyOptionsV1(
      {super.writeConcern, super.bypassDocumentValidation, super.comment})
      : super.protected();
}
