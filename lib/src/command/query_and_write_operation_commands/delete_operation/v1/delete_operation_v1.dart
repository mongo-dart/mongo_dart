import '../base/delete_operation.dart';
import 'delete_options_v1.dart';

class DeleteOperationV1 extends DeleteOperation {
  DeleteOperationV1(super.collection, super.deleteRequests,
      {DeleteOptionsV1? deleteOptions, super.rawOptions})
      : super.protected(deleteOptions: deleteOptions);
}
