import '../base/update_many_options.dart';

class UpdateManyOptionsOpen extends UpdateManyOptions {
  UpdateManyOptionsOpen(
      {super.writeConcern, super.bypassDocumentValidation, super.comment})
      : super.protected();
}
