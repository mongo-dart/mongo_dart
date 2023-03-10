import '../base/find_one_and_delete_operation.dart';
import 'find_one_and_delete_options_open.dart';

base class FindOneAndDeleteOperationOpen extends FindOneAndDeleteOperation {
  FindOneAndDeleteOperationOpen(super.collection, super.query,
      {super.fields,
      super.sort,
      super.session,
      super.hint,
      FindOneAndDeleteOptionsOpen? findOneAndDeleteOptions,
      super.rawOptions})
      : super.protected(findOneAndDeleteOptions: findOneAndDeleteOptions);
}
