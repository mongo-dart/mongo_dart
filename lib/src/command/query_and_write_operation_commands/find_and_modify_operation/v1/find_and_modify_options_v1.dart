import '../base/find_and_modify_options.dart';

class FindAndModifyOptionsV1 extends FindAndModifyOptions {
  FindAndModifyOptionsV1(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
