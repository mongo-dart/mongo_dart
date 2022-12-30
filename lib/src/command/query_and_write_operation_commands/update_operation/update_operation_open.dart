import 'base/update_operation.dart';
import 'update_options_open.dart';

class UpdateOperationOpen extends UpdateOperation {
  UpdateOperationOpen(super.collection, super.updates,
      {super.ordered, UpdateOptionsOpen? updateOptions, super.rawOptions})
      : super.protected(updateOptions: updateOptions);
}
