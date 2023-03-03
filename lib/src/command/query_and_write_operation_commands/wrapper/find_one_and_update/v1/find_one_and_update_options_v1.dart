import '../base/find_one_and_update_options.dart';

class FindOneAndUpdateOptionsV1 extends FindOneAndUpdateOptions {
  FindOneAndUpdateOptionsV1(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
