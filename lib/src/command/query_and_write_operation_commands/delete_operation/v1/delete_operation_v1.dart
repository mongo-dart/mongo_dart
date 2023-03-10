import '../base/delete_operation.dart';

base class DeleteOperationV1 extends DeleteOperation {
  DeleteOperationV1(super.collection, super.deleteRequests,
      {super.session, super.deleteOptions, super.rawOptions})
      : super.protected();
}
