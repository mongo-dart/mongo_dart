import '../base/find_and_modify_operation.dart';

base class FindAndModifyOperationOpen extends FindAndModifyOperation {
  FindAndModifyOperationOpen(super.collection,
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
