import '../base/update_operation.dart';

base class UpdateOperationV1 extends UpdateOperation {
  UpdateOperationV1(super.collection, super.updates,
      {super.ordered, super.session, super.updateOptions, super.rawOptions})
      : super.protected();
}
