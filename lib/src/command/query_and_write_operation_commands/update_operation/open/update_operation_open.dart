import '../base/update_operation.dart';

base class UpdateOperationOpen extends UpdateOperation {
  UpdateOperationOpen(super.collection, super.updates,
      {super.ordered, super.session, super.updateOptions, super.rawOptions})
      : super.protected();
}
