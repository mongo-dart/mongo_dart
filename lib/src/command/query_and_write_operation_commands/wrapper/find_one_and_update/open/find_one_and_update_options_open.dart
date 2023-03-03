import '../base/find_one_and_update_options.dart';

class FindOneAndUpdateOptionsOpen extends FindOneAndUpdateOptions {
  FindOneAndUpdateOptionsOpen(
      {super.bypassDocumentValidation,
      super.writeConcern,
      super.maxTimeMS,
      super.collation,
      super.comment})
      : super.protected();
}
