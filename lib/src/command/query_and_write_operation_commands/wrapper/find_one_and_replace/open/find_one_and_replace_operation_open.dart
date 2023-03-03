import '../base/find_one_and_replace_operation.dart';
import 'find_one_and_replace_options_open.dart';

class FindOneAndReplaceOperationOpen extends FindOneAndReplaceOperation {
  FindOneAndReplaceOperationOpen(
      super.collection, super.query, super.replacement,
      {super.fields,
      super.sort,
      super.upsert,
      super.returnNew,
      super.session,
      super.hint,
      FindOneAndReplaceOptionsOpen? findOneAndReplaceOptions,
      super.rawOptions})
      : super.protected(findOneAndReplaceOptions: findOneAndReplaceOptions);
}
