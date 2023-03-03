import '../base/find_one_and_delete_options.dart';

class FindOneAndDeleteOptionsOpen extends FindOneAndDeleteOptions {
  FindOneAndDeleteOptionsOpen(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
