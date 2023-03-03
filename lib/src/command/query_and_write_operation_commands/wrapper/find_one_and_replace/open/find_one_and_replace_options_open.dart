import '../base/find_one_and_replace_options.dart';

class FindOneAndReplaceOptionsOpen extends FindOneAndReplaceOptions {
  FindOneAndReplaceOptionsOpen(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
