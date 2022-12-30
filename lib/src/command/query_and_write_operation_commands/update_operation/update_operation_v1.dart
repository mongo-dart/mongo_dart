import 'base/update_operation.dart';
import 'update_options_v1.dart';

class UpdateOperationV1 extends UpdateOperation {
  UpdateOperationV1(super.collection, super.updates,
      {super.ordered, UpdateOptionsV1? updateOptions, super.rawOptions})
      : super.protected(updateOptions: updateOptions);
}
