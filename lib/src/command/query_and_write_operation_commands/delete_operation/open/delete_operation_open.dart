import '../base/delete_operation.dart';

base class DeleteOperationOpen extends DeleteOperation {
  DeleteOperationOpen(super.collection, super.deleteRequests,
      {super.session, super.deleteOptions, super.rawOptions})
      : super.protected();
}
