import '../base/delete_operation.dart';
import 'delete_options_open.dart';

class DeleteOperationOpen extends DeleteOperation {
  DeleteOperationOpen(super.collection, super.deleteRequests,
      {DeleteOptionsOpen? deleteOptions, super.rawOptions})
      : super.protected(deleteOptions: deleteOptions);
}
