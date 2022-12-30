import 'base/update_one_options.dart';

class UpdateOneOptionsOpen extends UpdateOneOptions {
  UpdateOneOptionsOpen(
      {super.writeConcern, super.bypassDocumentValidation, super.comment})
      : super.protected();
}
