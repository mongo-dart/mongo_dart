import '../base/find_one_and_replace_options.dart';

class FindOneAndReplaceOptionsV1 extends FindOneAndReplaceOptions {
  FindOneAndReplaceOptionsV1(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
