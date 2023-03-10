import '../base/find_one_and_replace_operation.dart';
import 'find_one_and_replace_options_v1.dart';

base class FindOneAndReplaceOperationV1 extends FindOneAndReplaceOperation {
  FindOneAndReplaceOperationV1(super.collection, super.query, super.replacement,
      {super.fields,
      super.sort,
      super.upsert,
      super.returnNew,
      super.session,
      super.hint,
      FindOneAndReplaceOptionsV1? findOneAndReplaceOptions,
      super.rawOptions})
      : super.protected(findOneAndReplaceOptions: findOneAndReplaceOptions);
}
