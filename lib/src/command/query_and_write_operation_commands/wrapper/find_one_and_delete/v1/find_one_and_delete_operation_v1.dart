import '../base/find_one_and_delete_operation.dart';
import 'find_one_and_delete_options_v1.dart';

class FindOneAndDeleteOperationV1 extends FindOneAndDeleteOperation {
  FindOneAndDeleteOperationV1(super.collection, super.query,
      {super.fields,
      super.sort,
      super.session,
      super.hint,
      FindOneAndDeleteOptionsV1? findOneAndDeleteOptions,
      super.rawOptions})
      : super.protected(findOneAndDeleteOptions: findOneAndDeleteOptions);
}
