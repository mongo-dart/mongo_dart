import '../base/find_and_modify_options.dart';

class FindAndModifyOptionsOpen extends FindAndModifyOptions {
  FindAndModifyOptionsOpen(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
