import '../base/find_one_and_delete_options.dart';

class FindOneAndDeleteOptionsV1 extends FindOneAndDeleteOptions {
  FindOneAndDeleteOptionsV1(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
