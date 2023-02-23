import '../base/find_and_modify_operation.dart';

class FindAndModifyOperationV1 extends FindAndModifyOperation {
  FindAndModifyOperationV1(super.collection,
      {super.query,
      super.sort,
      super.remove,
      required super.update,
      super.returnNew,
      super.fields,
      super.upsert,
      super.arrayFilters,
      super.session,
      super.hint,
      super.findAndModifyOptions,
      super.rawOptions})
      : super.protected();
}
